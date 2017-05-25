# 呼叫车辆API



## 乘客端

| 协议   | 类型        | API               | 描述               |
| ---- | --------- | ----------------- | :--------------- |
| HTTP | GET       | region            | 根据位置获取区域 id      |
| MQTT | Subscript | region/:id/driver | 根据区域 id 获取附近车辆信息 |
| HTTP | POST      | order/preview     | 根据起点终点坐标获取订单基本信息 |
| HTTP | POST      | order/request     | 根据起点终点坐标返回订单编号   |
| MQTT | Subscript | order/:id/rider   | 监听订单状态, 等待司机信息   |
| HTTP | POST      | order/:id/cancle  | 取消订单             |
| HTTP | POST      | order/:id/comment | 订单完成,支付评价        |
| HTTP | GET       | order/current     | 获取当前订单           |




## 司机端

| 协议   | 类型        | API                 | 描述                 |
| ---- | --------- | ------------------- | ------------------ |
| MQTT | Publish   | driver/location/:id | 上报自身位置             |
| HTTP | POST      | driver/status       | 改变司机状态 (可接单/不可接单)  |
| MQTT | Subscript | driver/waitorder    | 等待接单               |
| HTTP | GET       | order/:id           | 确认接单获取目标位置         |
| MQTT | Subscript | order/:id/driver    | 监听订单状态, 判断订单是否中途取消 |
| HTTP | POST      | order/:id/status    | 变更 上车/下车 状态        |
| HTTP | GET       | order/current       | 获取当前订单             |



## 服务端

| 源Topic                 | 目标Topic                | 描述          |
| ---------------------- | ---------------------- | ----------- |
| MQTT driver/location/+ | MQTT order/:id/rider   | 转发司机位置到当前订单 |
| MQTT driver/location/+ | MQTT region/:id/driver | 转发司机位置到指定区域 |



## 订单状态

- 已收到请求
- 正在搜索司机
- 接单失败(msg: 失败信息)
- 接单成功(msg: 司机信息)
- 等待车辆到达(location: 司机位置)
- 已上车
- 车辆行驶信息(location: 司机位置)
- 已下车
- 支付状态(bool: 成功/失败, msg: 信息) 
- 已取消