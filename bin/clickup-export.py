#!env python3
# https://github.com/jpetrucciani/pyclickup

from pyclickup import ClickUp
from pprint import pprint
from collections import defaultdict
import re
import datetime

def handleFieldTeam(field):
    if 'value' in field:
        fval = field["type_config"]["options"][field["value"]]
        return f'{field["name"]} {fval["name"]}'

handleCustomField = {
    'Team': handleFieldTeam
}

def group_tasks_by_status(lst):
    tasks = lst.get_all_tasks(include_closed=True)
    groups = defaultdict(list)
    for t in tasks:
        groups[t.status.status].append(t)
    return groups

def group_tasks_by_leveling(lst):
    tasks = lst.get_all_tasks(include_closed=True)
    groups = defaultdict(list)
    for t in tasks:
        key=getCustomFieldValue('leveling', t)
        keyStr=', '.join(key)
        groups[keyStr].append(t)
    return groups

def group_tasks_by_levelitem(tasks):
    groups = defaultdict(list)
    for t in tasks:
        key=getCustomFieldValue('lvl:item', t)
        keyStr=', '.join(key) if key else "None"
        groups[keyStr].append(t)
    return groups

def print_leveling(groups):
    for grpName, tasks in groups.items():
        print(f'\n\n## {grpName}')
        subgroups=group_tasks_by_levelitem(tasks)
        for lvlitem, tasks2 in subgroups.items():
            print(f'\n### {lvlitem}')
            sorted_tasks2 = sorted(tasks2, key=lambda t: t.due_date)
            bullets=task_bullets_for_leveling(sorted_tasks2)
            print("\n".join(bullets))
    print('\n')


def print_standup(groups):
    print(':slack: [Standup](https://share.clickup.com/l/h/80kzt-322/33aebd1524f89d8)')
    print(':slack:')

    print('\n**Finished** :ballot_box_with_check:')
    bullets=task_bullets_for_standup(groups['merged'], printStatus=True)
    bullets+=task_bullets_for_standup(groups['completed'])
    bullets+=task_bullets_for_standup(groups['Closed'])
    if bullets:
        print("\n".join(bullets))
    else:
        print("  * :sad_cowboy:")

    print('\n**Working on** :running_turkey:')
    bullets=task_bullets_for_standup(groups['in progress'])
    if bullets:
        print("\n".join(bullets))
    else:
        print("  * :man-shrugging:")

    print('\n**Blocked on** :question_block:')
    bullets=task_bullets_for_standup(groups['blocked'])
    bullets+=task_bullets_for_standup(groups['back to owner'], printStatus=True)
    bullets+=task_bullets_for_standup(groups['review'], printStatus=True)
    if bullets:
        print("\n".join(bullets))
    else:
        print("  * :nope:")

    print('\n**Up Next** :clipboard:')
    bullets=task_bullets_for_standup(groups['next'])
    if bullets:
        print("\n".join(bullets))
    else:
        print("  * :man-shrugging:")

    print('\n')


class Percent(float):
    def __str__(self):
        return '{:.0%}'.format(self)

teamToEmoji = {
    'Bat Team': ":bat:",
    'Caseflow': ":caseflow:",
    'Data': ":bar_chart:",
    'Delta': ":delta:",
    'Echo': ":tiny_echo:",
    'NAVA': ':nava:'
}

def task_bullets_for_standup(tasks, printStatus=False, printTeam=True, printProgress=False):
    bullets=[]
    for t in tasks:
        if getCustomFieldValue('reported?', t) == 'true':
            continue
        bullet="  *"
        if printTeam:
            team=getCustomFieldValue('Team', t)
            if team:
                if team in teamToEmoji:
                    teamStr = teamToEmoji[team]
                else:
                    teamStr = f'*[{team}]*'
                bullet+=f' {teamStr}'
        if printStatus:
            bullet+=f' *({t.status.status})*'
        if printProgress:
            progress=getCustomFieldValue('est. progress', t)
            percent=Percent(progress['percent_completed'])
            bullet+=f' ({percent} progress)'
        url=getCustomFieldValue('url', t)
        if url:
            if re.compile(r'#[0-9]+').search(t.name):
                task_text=re.sub(r"(#[0-9]+)", f'[\g<1>]({url})', t.name)
                bullet+=f' {task_text}'
            else:
                bullet+=f' [{t.name}]({url})'
        else:
            bullet+=f' {t.name}'
        bullets.append(bullet)
    return bullets


def task_bullets_for_leveling(tasks, printTeam=True):
    bullets=[]
    for t in tasks:
        due_date=t.due_date.strftime("%Y-%m")
        # if getCustomFieldValue('reported?', t) == 'true':
        #     continue
        bullet=f"  * {due_date}"
        if printTeam:
            team=getCustomFieldValue('Team', t)
            if team:
                teamStr = f'*[{team}]*'
                bullet+=f' {teamStr}'
        if len(t.tags) > 0:
            bullet+=f' (tags: {",".join([tag.name for tag in t.tags])})'
        priority=t.priority['priority'] if t.priority else 'normal'
        if priority != 'normal':
            bullet+=f' ({priority})'
        url=getCustomFieldValue('url', t)
        if url:
            if re.compile(r'#[0-9]+').search(t.name):
                task_text=re.sub(r"(#[0-9]+)", f'[\g<1>]({url})', t.name)
                bullet+=f' {task_text}'
            else:
                bullet+=f' [{t.name}]({url})'
        else:
            bullet+=f' {t.name}'
        bullets.append(bullet)
    return bullets


def print_tasks_details(groups):
    for status, tasks in groups.items():
        for t in tasks:
            # pprint(vars(t))
            print(f'* [{t.status.status}] {t.name}')
            if t.description:
                descr=t.description.strip().replace("\n","\n    - ")
                print(f'  - {descr}')
            if len(t.tags) > 0:
                print(f'  - tags: {",".join([tag.name for tag in t.tags])} ')
            for field in t.custom_fields:
                if 'name' in field:
                    func=handleCustomField.get(field["name"], None)
                    # print(f'func={func}')
                    if func:
                        valStr=func(field)
                        if valStr:
                            print(f'  - {valStr} ')
            if t.parent:
                print(f'  - parent: {t.parent} ')

def getObjectWithName(name, arr):
    return next(p for p in arr if p.name==name)

def getObjectWithNameKey(name, arr):
    return next(p for p in arr if p["name"]==name)

def getObjectWithIdKey(name, arr):
    return next(p for p in arr if p["id"]==name)

def getCustomFieldValue(name, task):
    custField=getObjectWithNameKey(name, task.custom_fields)
    # pprint(custField)
    if 'value' not in custField:
        return None
    if custField['type'] == 'drop_down':
        fval=custField["type_config"]["options"][custField["value"]]
        return fval["name"]
    elif custField['type'] == 'labels':
        fvals=[]
        for val in custField["value"]:
            fval=getObjectWithIdKey(val, custField["type_config"]["options"])
            fvals.append(fval["label"])
        return fvals
    else: # 'checkbox'
        fval=custField["value"]
    return fval

def getProjects():
    clickup = ClickUp("pk_10518296_U77W5I8O5BDCGUC48562OE9YD9IWKBT9")
    main_team = clickup.teams[0]
    main_space = main_team.spaces[0]
    #members = main_space.members
    projects = main_space.projects
    return projects

def getLists(project, listnames):
    proj = next(p for p in projects if p.name==project)
    lists = [ l for l in proj.lists if l.name in listnames ]
    # for lst in lists:
    #     print_tasks_details(group_tasks_by_status(lst))
    return lists

def print_stats(groups):
    for k,v in groups.items():
        print(f"{k} => {len(v)}", file=sys.stderr)

def standup():
    lists=getLists("Task Management", ["Tasklist"])
    groups=group_tasks_by_status(lists[0])
    print(f'\n## {lists[0].name} {datetime.datetime.today().strftime("%Y-%m-%d")}')
    print_stats(groups)
    print_standup(groups)

def leveling():
    lists=getLists("Task Management", ["Done-2020-B"])
    # nava_lists=getLists("Nava", ["Done-Nava-2020-B"])
    groups=group_tasks_by_leveling(lists[0])
    print_stats(groups)
    print_leveling(groups)

import sys
if __name__ == "__main__":
    print(sys.argv, file=sys.stderr)
    projects = getProjects()

    if len(sys.argv) == 1:
        print("Creating markdown for Standup", file=sys.stderr)
        standup()
    elif sys.argv[1] == "leveling":
        print("Creating markdown for Leveling", file=sys.stderr)
        leveling()

    # main()

