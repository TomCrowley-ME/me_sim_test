'''
Created on Jun 17, 2014

@author: tklaus
'''
import csv
import sys
import re

funcs = ['sin','cos','pi','sind','cosd','e','rand','sqrt','date2seconds']
regex = re.compile("[a-zA-Z][a-zA-Z0-9_.]*") # match variable names within MATLAB expressions

def adorn(match):
    if match.group() in funcs:
        return match.group()
    else:
        return "${" + match.group() + "}"

if __name__ == '__main__':
    
    with open('../../seed/total_tunable_vars.csv', 'rb') as csvfile, open('../../seed/total_tunable_vars_adorned.csv', 'wb') as newcsvfile:
        seed_data = csv.reader(csvfile, delimiter=',')
        for row in seed_data:
            row_str = ','.join(row)

            #print(row)
            if len(row) != 6:
                print('invalid line: {}'.format(row))
                sys.exit(0)
            row[5] = "\"{}\"".format(regex.sub(adorn, row[5]).strip())
            
            print('row[5]: {}'.format(row[5]))

            row_str = ','.join(row)
            '''            
            all_vars = regex.findall(value_expression)
            #print('all_vars: {}'.format(all_vars))
            for var in all_vars:
                if var not in funcs:
                    replacement = "${" + var + "}"

                    print('var: {}'.format(var))
                    print('replacement: {}'.format(replacement))
                    
                    print('row_str: {}'.format(row_str))
                    row_str = row_str.replace(var, replacement)
                    print('row_str: {}'.format(row_str))
            '''
            
            newcsvfile.write(row_str + "\n")




