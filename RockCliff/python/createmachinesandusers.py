from citrix import citrix
from sys import exit
from time import sleep

c = citrix()

# Provide a list of users who need access to a new machine
upns = ['Arthur.Ursula@phoenixfinancialcapital.onmicrosoft.com', 'Merle.Jenny@phoenixfinancialcapital.onmicrosoft.com']

# Add number of machines to the catalog equal to the number of users to be provisioned
machinecreationresponse = c.addmachinestocatalog(count=len(upns))

# Do not continue on until the job shows as completed, check every 5 seconds
machinecreationjobstatus = c.getjobstatus(machinecreationresponse[1])
jobstatuses = [ 'NotStarted', 'InProgress']
failjobstatuses = ['Failed', 'Canceled', 'NonTerminatingError']
while machinecreationjobstatus in jobstatuses:
    print(f"Current job status to create machines is: {machinecreationjobstatus}")
    sleep(5)
    machinecreationjobstatus = c.getjobstatus(machinecreationresponse[1])
if machinecreationjobstatus in failjobstatuses:
    print(f'Job finished in a bad state with status: {machinecreationjobstatus}')
    exit(1)
print(f'Jobs status is now: {machinecreationjobstatus}. Moving on to catalog and user assignment')

# Get machines in catalog that have no users assigned to them
machineswithoutassignedusers = []
for i in c.getmachines(c.CATALOGID)['Items']:
    if i['AssignedUsers'] == []:
        machineswithoutassignedusers.append(i['Name'])

# Add machines without users assigned to delivery group and assign users. We build a dictionary using dictionary comprehension for the machine to upn mappings
machineusermappingdict = {upns[i]: machineswithoutassignedusers[i] for i in range(len(upns))}
machineassignmentresponse = (c.addcatalogmachinetodeliverygroup(machineusermappingdict))

print("The following users were assigned to machines successfully:")
for user,machine in machineusermappingdict.items():
    print(f'{user} was assigned to {machine}')