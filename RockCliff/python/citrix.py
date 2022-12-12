import requests
import pandas as pd
import json
import time
from sys import exit

class citrix:
    CUSTOMERID = "m5aroy32eg73" 
    CLIENTID = "d086ca3c-34a3-479b-8f80-3027b9b1b670"
    SECRET = "atH2lQ8te08C2aSyV3VJvA=="
    SITEID = "2203adb7-9498-4cb4-8e29-551d6bea0296"
    ENDPOINT = "https://api-us.cloud.com"
    DELIVERYGROUPID = "7c1aff2e-34ce-4d53-8729-eca9dc17c8de"
    CATALOGID = "50101750-0ea7-4e65-b3b8-74541c235be7"

    def __init__(self):
        self.token = self.gettoken()
        self.authheaders = {
            'Authorization': f'CwsAuth Bearer={self.token}',
            'Citrix-CustomerId': self.CUSTOMERID,
            'Citrix-InstanceId': self.SITEID,
            'Content-Type': 'application/json'
        }

    def gettoken(self):
        authendpoint = f"{self.ENDPOINT}/cctrustoauth2/{self.CUSTOMERID}/tokens/clients"
        self.r = requests.Session()
        self.r.headers = {
            'Accept' :'application/json',
            'Content-Type': 'application/x-www-form-urlencoded'
        }

        tokenresponse = self.r.request("POST",authendpoint,data = {
            'grant_type': 'client_credentials',
            'client_id': self.CLIENTID,
            'client_secret': self.SECRET
        }).json()
        
        return tokenresponse['access_token']

    def getsites(self):
        endpoint = f'{self.ENDPOINT}/catalogservice/{self.CUSTOMERID}/sites'
        headers = {
            'Authorization': f'CwsAuth Bearer={self.token}',
            }
        self.r.headers.update(headers)

        response = self.r.request("GET",endpoint).json()

        return response
        
    def createmachinecatalog(self):
        endpoint = f'{self.ENDPOINT}/cvad/manage/MachineCatalogs'
        
        machinecatalogname = 'Phoenix Financial Capital Machine Catalog'
        masterimagepath = "XDHyp:\\Citrix-MasterImages\\DASImggcjxb1-disk-txvhuswk2t.manageddisk"
        machineprofilepath = "XDHyp:\\rg-boss-bass\\Ctxs-MachineProfile-eni3\\v1"

        body = {
        "Name": machinecatalogname,
        "AllocationType": "Static",
        "IsRemotePC": 'false',
        "MachineType": "MCS",
        "MinimumFunctionalLevel": "L7_9",
        "PersistUserChanges": "OnLocal",
        "ProvisioningType": "MCS",
        "AllocationType": "Static",
        "SessionSupport": "SingleSession",
        "MasterImagePath": masterimagepath,
        "MachineProfilePath": machineprofilepath
        }
        
        try:
            response = self.r.request("POST",endpoint,json=body)
            response.raise_for_status()
        except requests.exceptions.HTTPError as err:
            raise SystemExit(err)

        return response

    def addmachinestocatalog(self,count=1):
        
        self.r.headers.update(self.authheaders)

        if count == 1:
            endpoint = f'{self.ENDPOINT}/cvad/manage/MachineCatalogs/{self.CATALOGID}/Machines?async=true'
            body = {
                'MachineAccountCreationRules': {
                    'NamingScheme': 'boss-bass-#',
                    'NamingSchemeType': 'Numeric'
                }
            }
            try:
                response = self.r.request("POST",endpoint,json=body)
                response.raise_for_status()
            except requests.exceptions.HTTPError as err:
                raise SystemExit(err)
            jobid = (response.headers['Location']).rsplit('/',1)[-1]
            response = "No response provided for single machine provisioning"

        else:
            endpoint = f'{self.ENDPOINT}/cvad/manage/$batch'
            body = {
                "Items": []
                }
            reference = 0
            while len(body['Items']) != count:
                bodyrequest = {
                    "Reference": reference,
                    "Method": "POST",
                    "RelativeUrl": f"/MachineCatalogs/{self.CATALOGID}/Machines",
                    "Body": "{\"MachineAccountCreationRules\":{\"NamingScheme\":\"boss-bass-#\",\"NamingSchemeType\":\"Numeric\"}}"
                }
                reference += 1
                body['Items'].append(bodyrequest)
            try:
                response = self.r.request("POST",endpoint,json=body)
                response.raise_for_status()
            except requests.exceptions.HTTPError as err:
                raise SystemExit(err)
            jobid = json.loads(response.text)['Items'][0]['Headers'][0]['Value'].rsplit('/',1)[-1]

        return response,jobid

    def getjobresults(self,jobid):
        endpoint = f'{self.ENDPOINT}/cvad/manage/Jobs/{jobid}/results'

        self.r.headers.update(self.authheaders)
        response = self.r.request("GET",endpoint,data={}).json()

        return response
    
    def getjobstatus(self,jobid):
        endpoint = f'{self.ENDPOINT}/cvad/manage/Jobs/{jobid}'

        self.r.headers.update(self.authheaders)
        response = self.r.request("GET",endpoint,data={}).json()

        return response['Status']

    def addcatalogmachinetodeliverygroup(self,machineusermappingdict):
        endpoint = f'{self.ENDPOINT}/cvad/manage/DeliveryGroups/{self.DELIVERYGROUPID}/Machines?async=true'

        machineuserbodylist = []
        for user,machine in machineusermappingdict.items():
            machineuserbodyobj = {
                'Machine': machine,
                'Users': [f'AzureAD:{user}']
            }
            machineuserbodylist.append(machineuserbodyobj)

        body = {
                "MachineCatalog":  self.CATALOGID,
                'AssignMachinesToUsers': 
                    machineuserbodylist
                    # [
                    # {
                    #     'Machine': 'boss-bass-1',
                    #     'Users': ['AzureAD:Jeri.Ignacio3@phoenixfinancialcapital.onmicrosoft.com']
                    # },
                    # {
                    #     'Machine': 'boss-bass-2',
                    #     'Users': ['AzureAD:sherwin.deidre@phoenixfinancialcapital.onmicrosoft.com']
                    # },
                    # {
                    #     'Machine': 'boss-bass-3',
                    #     'Users': ['AzureAD:velda.nila@phoenixfinancialcapital.onmicrosoft.com']
                    # }
                    # ]
            }

        try:
            response = self.r.request("POST",endpoint,json=body)
            response.raise_for_status()
        except requests.exceptions.HTTPError as err:
            raise SystemExit(err)

        return response

    def getmachinecatalogs(self):
        endpoint = f'{self.ENDPOINT}/cvad/manage/MachineCatalogs'

        self.r.headers.update(self.authheaders)
        response = self.r.request("GET",endpoint,data={}).json()

        return response

    def getdeliverygroups(self):
        endpoint = f'{self.ENDPOINT}/cvad/manage/DeliveryGroups'

        self.r.headers.update(self.authheaders)
        response = self.r.request("GET",endpoint,data={}).json()

        return response

    def getjobs(self):
        endpoint = f'{self.ENDPOINT}/cvad/manage/Jobs'

        self.r.headers.update(self.authheaders)
        response = self.r.request("GET",endpoint,data={}).json()

        return response

    def getmachines(self,machinecatalog):
        endpoint = f'{self.ENDPOINT}/cvad/manage/MachineCatalogs/{machinecatalog}/Machines'

        self.r.headers.update(self.authheaders)
        response = self.r.request("GET",endpoint,data={}).json()

        return response

    def poweronmachines(self,machinename):
        endpoint = f'{self.ENDPOINT}/cvad/manage/Machines/{machinename}/$start?async=true'

        response = self.r.request("POST",endpoint,data={})

        return response

# if __name__ == '__main__':
#     c = citrix()