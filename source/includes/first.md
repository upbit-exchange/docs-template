# UpbitClient (Upbit 클라이언트 사용하기)

> Code Example

```python
from upbit.client import Upbit

access_key = "발급받은 액세스 키"
secret_key = "발급받은 시크릿 키"

client = Upbit(access_key, secret_key)
print(client)
```

> Result Example

```console
UpbitClient(https://api.upbit.com/v1)
```

설치가 완료되면 `from upbit.client import Upbit`로 패키지를 import 합니다.
그 다음 `UpbitClient` 객체를 생성하면 클라이언트를 사용할 준비가 완료됩니다.


### UpbitClient(access_key, secret_key, **kwargs)

Parameter  | Description
---------- | -----------
access_key | 발급받은 액세스 키
secret_key | 발급받은 시크릿 키
spec_uri   | Swagger Mapping JSON Path 
config     | Swagger Client Configuration
