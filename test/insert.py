import names
import random
import requests
import json
data=[]

baseUrl = 'http://118.24.93.22'

for i in range(20):
    name = names.get_full_name();
    email = name.replace(' ', '').lower()+'@mail.com'
    tel = '1%d'%random.randint(1000000000, 9999999999)
    data.append({
        'name': name, 
        'email': email,
        'id': '201801'+ '0'*(3-len(str(i)))+str(i),
        'phonenumber': tel
    })
print(data)
res= requests.post(baseUrl+ '/api/user/login', json={'id': 'admin', 'password':'helloworld'})
print(json.loads(res.content)['token'])

r =  requests.post(baseUrl+'/api/student/insert', json={'data': data}, cookies=res.cookies);
print(r.content)



