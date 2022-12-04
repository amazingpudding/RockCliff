import requests
import argparse
import json

class citrix:
    CUSTOMERID = "nhlfmfxoftji" 
    CLIENTID = "20d0656c-5ef5-4a13-9a4a-a0885f1f053c"
    SECRET = "mhNLTO_IyDCjyjC70OKyqQ=="
    SITEID = "627a0f57-7d7d-4fe2-aca1-757f8e00396f"
    ENDPOINT = "https://api-us.cloud.com"
    
    def __init__(self):
        self.token = self.gettoken()

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


    # def getcatalog(self):
    #     endpoint = f'{self.ENDPOINT}/catalogservice/{self.CUSTOMERID}/{self.SITEID}/managedcatalogs'
    #     headers = {            
    #         'Authorization': f'CwsAuth Bearer={self.token}',
    #     }
    #     self.r.headers.update(headers)

    #     response = self.r.request("GET",endpoint,data={}).json()

    #     return response
    
    def getcatalogs(self):
        endpoint = f'{self.ENDPOINT}/cvad/manage/MachineCatalogs'
        headers = {            
            'Authorization': f'CwsAuth Bearer={self.token}',
            'Citrix-CustomerId': self.CUSTOMERID,
            'Citrix-InstanceId': self.SITEID,
            'Content-Type': 'application/json'
        }
        self.r.headers.update(headers)

        response = self.r.request("GET",endpoint,data={})

        return response


if __name__ == '__main__':
    c = citrix()
    print(c.getcatalogs())
