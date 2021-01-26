
# WebSocket (웹 소켓)

## UpbitWebSocket
웹 소켓 클래스를 생성합니다.

> Example Code

```python
from upbit.websocket import UpbitWebSocket

sock = UpbitWebSocket()
```

### Parameters

Parameter      | Description
-------------- | --------------------
uri            | 웹 소켓에 연결할 URI. (기본값: `wss://api.upbit.com/websocket/v1`)
ping_interval  | ping 간격 제한 (기본값: `None`)
ping_timeout   | ping 시간 초과 제한 (기본값: `None`)


## sock.Connection
**Property**

웹 소켓에 연결하기 위해 생성된 Connection 객체입니다.

> Example Code

```python
from upbit.websocket import UpbitWebSocket

sock = UpbitWebSocket()

async with sock.Connection as conn:
    # Do Something
    pass
```


## conn.send
웹 소켓에 데이터를 수신합니다.

> Example Code

```python
from upbit.websocket import UpbitWebSocket

sock = UpbitWebSocket()

async with sock.Connection as conn:
    await conn.send('PING')
```

### Parameters

Parameter      | Description
-------------- | --------------------
message        | 서버에 수신할 데이터


## conn.recv
서버로부터 전달받은 바이트 스트림(bytes stream) 데이터를 받습니다.

> Example Code

```python
import re
import json
from upbit.websocket import UpbitWebSocket

sock = UpbitWebSocket()

async with sock.Connection as conn:
    await conn.send('PING')
    data = await conn.recv()

    pattern = re.compile('{"\S+":"\S+"}')
    search = pattern.search(data.decode('utf8'))
    result = json.loads(search.group())
    print(result)
```

> Result

```python
{'status': 'UP'}
```

### Parameters

No Parameters


## UpbitWebSocket.generate_payload (Payload Generate)
**staticmethod**

웹 소켓 수신에 필요한 payload 데이터를 json 형식에 맞춰진 문자열로 generate 합니다.

> Example Code

```python
from upbit.websocket import UpbitWebSocket

currencies = ["KRW-BTC", "KRW-ETH"]
payload = UpbitWebSocket.generate_payload(type="trade", codes=currencies)
print(payload)
```

> Result

```python
[
    {
        "ticket": "0e9a7960-4036-4cf3-abe6-c02712c3aad4"
    },
    {
        "type": "trade",
        "codes": ["KRW-BTC", "KRW-ETH"]
    },
    {
        "format": "DEFAULT"
    }
]
```

### Parameters

Parameter      | Description
-------------- | --------------------
ticket         | 식별값 (기본값은 `uuid4` 형식으로 생성)
type *         | 수신할 시세 타입 (현재가: `ticker`, 체결: `trade`, 호가: `orderbook`)
codes *        | 수신할 시세 종목 정보 (ex. `['KRW-BTC', 'KRW-ETH']`)
isOnlySnapshot | 시세 스냅샷만 제공 여부 (`True`, `False`)
isOnlyRealtime | 실시간 시세만 제공 여부 (`True`, `False`)
format         | 포맷, `SIMPLE`: 간소화된 필드명, `DEFAULT`: 기본 포맷 (생략 가능)


## UpbitWebSocket.generate_orderbook_codes (Orderbook Codes Generate)
**staticmethod**

`type` 파라미터가 `orderbook`일 경우에 필요한 `codes` 파라미터를 요청 형식에 맞춰 generate 합니다.

> Example Code

```python
from upbit.websocket import UpbitWebSocket

currencies = ["KRW-BTC", "KRW-ETH"]
counts = [5, 5]
codes = UpbitWebSocket.generate_orderbook_codes(
    currencies, counts)
print(codes)
```

> Result

```python
["KRW-BTC.5", "KRW-ETH.5"]
```

### Parameters

Parameter      | Description
-------------- | --------------------
currencies     | 수신할 시세 종목들
counts         | 수신할 각 시세 종목에 대한 개수


## Request (시세 정보 요청하기)
웹 소켓을 통해 시세 정보를 요청합니다.

> Example Code

```python
import json
import asyncio

from upbit.websocket import UpbitWebSocket


# Definition async function
async def trade(sock, payload):
    async with sock.Connection as conn:
        await conn.send(payload)
        data = await conn.recv()
        result = json.loads(data.decode('utf8'))
        print(result)


sock = UpbitWebSocket()

currencies = ["KRW-BTC", "KRW-ETH"]
payload = sock.generate_payload(
    type="trade", codes=currencies)

event_loop = asyncio.get_event_loop()
event_loop.run_until_complete(trade(sock, payload))
```

> Result

```json
{
    "type": "trade",
    "code": "KRW-BTC",
    "timestamp": 1611656099678,
    "trade_date": "2021-01-26",
    "trade_time": "10:14:59",
    "trade_timestamp": 1611656099000,
    "trade_price": 35785000.0,
    "trade_volume": 0.00533827,
    "ask_bid": "ASK",
    "prev_closing_price": 36054000.0,
    "change": "FALL",
    "change_price": 269000.0,
    "sequential_id": 1611656099000000,
    "stream_type": "SNAPSHOT"
}
```

### Parameters

Parameter      | Description
-------------- | --------------------
payload        | 요청 데이터


### Response


**현재가(Ticker) 응답**

필드명                      | 축약형 (format: SIMPLE) | 내용                | 타입  | 값
-------------------------- | ---------------------- | ------------------- | ----- | -----
type                       | ty           | 타입                           | String | `ticker` : 현재가
code                       | cd           | 마켓 코드 (ex. KRW-BTC)        | String | -
opening_price              | op           | 시가                           | Double | -
high_price                 | hp           | 고가                           | Double | -
low_price                  | lp           | 저가                           | Double | -
trade_price                | tp           | 현재가                         | Double | -
prev_closing_price         | pcp          | 전일 종가                      | Double | 
change                     | c            | 전일 대비                      | String | `RISE`: 상승, `EVEN`: 보합, `FALL`: 하락
change_price               | cp           | 부호 없는 전일 대비 값          | Double | -
signed_change_price        | scp          | 전일 대비 값                   | Double | -
change_rate                | cr           | 부호 없는 전일 대비 등락율      | Double | -
signed_change_rate         | scr          | 전일 대비 등락율               | Double | -
trade_volume               | tv           | 가장 최근 거래량               | Double | -
acc_trade_volume           | atv          | 누적 거래량(UTC 0시 기준)      | Double | -
acc_trade_volume_24h       | atv24h       | 24시간 누적 거래량              | Double | -
acc_trade_price            | atp          | 누적 거래대금(UTC 0시 기준)     | Double | -
acc_trade_price_24h        | atp24h       | 24시간 누적 거래대금            | Double | -
trade_date                 | tdt          | 최근 거래 일자(UTC)            | String | `yyyyMMdd`
trade_time                 | ttm          | 최근 거래 시각(UTC)            | String | `HHmmss`
trade_timestamp            | ttms         | 체결 타임스탬프 (milliseconds) | Long | -
ask_bid                    | ab           | 매수/매도 구분                 | String  | `ASK`: 매도, `BID`: 매수
acc_ask_volume             | aav          | 누적 매도량                    | Double | -
acc_bid_volume             | abv          | 누적 매수량                    | Double | -
highest_52_week_price      | h52wp        | 52주 최고가                    | Double | -
highest_52_week_date       | h52wdt       | 52주 최고가 달성일              | String | `yyyy-MM-dd`
lowest_52_week_price       | l52wp        | 52주 최저가                    | Double | -
lowest_52_week_date        | l52wdt       | 52주 최저가 달성일              | String |`yyyy-MM-dd`
trade_status               | ts           | 거래상태 *deprecated           | String | -
market_state               | ms           | 거래상태                       | String | `PREVIEW`: 입금지원, `ACTIVE`: 거래지원가능, `DELISTED` : 거래지원종료
market_state_for_ios       | msfi         | 거래 상태 *deprecated          | String | - 
is_trading_suspended       | its          | 거래 정지 여부                  | Boolean | - 
delisting_date             | dd           | 상장폐지일                      | Date  | -
market_warning             | mw           | 유의 종목 여부                  | String | `NONE`: 해당없음, `CAUTION`: 투자유의
timestamp                  | tms          | 타임스탬프 (milliseconds)       | Long | -
stream_type                | st           | 스트림 타입                     | String | `SNAPSHOT`: 스냅샷, `REALTIME`: 실시간


**체결(Trade) 응답**

필드명 | 축약형 (format: SIMPLE) | 내용 | 타입 | 값
----- | ------------------------ | --- | --- | ----
type | ty | 타입 | String | `trade`: 체결
code | cd | 마켓 코드 (ex. KRW-BTC) | String | - 
trade_price | tp | 체결 가격 | Double | -
trade_volume | tv | 체결량 | Double | -
ask_bid | ab | 매수/매도 구분 | String | `ASK`: 매도, `BID`: 매수
prev_closing_price | pcp | 전일 종가 | Double | -
change | c | 전일 대비 | String | `RISE` : 상승, `EVEN` : 보합, `FALL` : 하락
change_price | cp | 부호 없는 전일 대비 값 | Double | -
trade_date | td | 체결 일자(UTC 기준) | String | `yyyy-MM-dd`
trade_time | ttm | 체결 시각(UTC 기준) | String | `HH:mm:ss`
trade_timestamp | ttms | 체결 타임스탬프 (millisecond) | Long | -
timestamp | tms | 타임스탬프 (millisecond) | Long | -
sequential_id | sid | 체결 번호 (Unique) | Long | -
stream_type | st | 스트림 타입 | String | `SNAPSHOT`: 스냅샷, `REALTIME`: 실시간

<aside class="notice">
    <code>sequential_id</code> 필드는 체결의 유일성 판단을 위한 근거로 쓰일 수 있습니다.
    <br/>
    하지만 체결의 순서를 보장하지는 못합니다.
</aside>


**호가(Orderbook) 응답**

필드명 | 축약형 (format: SIMPLE) | 내용 | 타입 | 값
------ | ----------------------- | --- | --- | -------
type | ty | 타입 | String | `orderbook`: 호가
code | cd | 마켓 코드 (ex. KRW-BTC) | String | - 
total_ask_size | tas | 호가 매도 총 잔량 | Double | - 
total_bid_size | tbs | 호가 매수 총 잔량 | Double | -
orderbook_units | obu | 호가 | List of Objects | -
ask_price | ap | 매도 호가 | Double | -
bid_price | bp | 매수 호가 | Double | -
ask_size | as | 매도 잔량 | Double | -
bid_size | bs | 매수 잔량 | Double | -
timestamp | tms | 타임스탬프 (millisecond) | Long | -