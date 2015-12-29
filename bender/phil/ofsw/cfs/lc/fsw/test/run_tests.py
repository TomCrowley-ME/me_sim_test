
from subprocess import call

tests = [
    'test_LC_1',
    'test_LC_2'
    ]

for test in tests:
    print('Running test: {}'.format(test))
    
    rc = call(['./' + test])
    
    print('Test {} completed, rc = {}'.format(test, rc))
    
print()
print('*********** TEST RESULTS **********') 
print()

for test in tests:
    rc = call(['diff', '-I', '.*ES Startup.*', 
               '{}.ActualOutput'.format(test), '{}.ExpectedOutput'.format(test)])
    
    if rc:
        result = 'FAILED'
    else:
        result = 'PASSED'
    
    print(test + ' : ' + result)
    
print()
