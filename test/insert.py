import names
import random
import requests
import json
data=[]
for i in range(1):
    name = names.get_full_name();
    email = name.replace(' ', '').lower()+'@mail.com'
    tel = '1%d'%random.randint(1000000000, 9999999999)
    data.append({
        'name': name, 
        'email': email,
        'id': '201802'+ '0'*(3-len(str(i)))+str(i),
        'phonenumber': tel
    })
print(data)
# res= requests.post('http://118.24.93.22/api/user/login', json={'id': 'admin', 'password':'helloworld'})
# print(json.loads(res.content)['token'])

# r =  requests.post('http://118.24.93.22/api/student/insert', json={'data': data}, cookies=res.cookies);
# print(r.content)