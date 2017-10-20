select  TASK_PARAMS ,
replace(substring(
substring(TASK_PARAMS,instr(TASK_PARAMS,'itemName')),1,
instr(substring(TASK_PARAMS,instr(TASK_PARAMS,'itemName')),',')-2
),'itemName":"','')
from task_detail where TASK_GROUP like '%api%' limit 100


-- getMktEqud
,"itemName":"getMktEqud",
{"CCEmailUsr":"team.stock@datayes.com,xi.zhang@datayes.com,yedong.jiang@datayes.com","api":"v1/api/market/getMktEqud.json","checkUser":["yafan.bai@datayes.com","wenqin.qiu@datayes.com"],"emailUsr":"dept.data@datayes.com","errorEmailUser":"bin.yang@datayes.com","exchangeCd":"XSHG","itemName":"getMktEqud","monitorName":"股票日线行情","params":[{"reference":"AVG","relativeCompareType":"SUB1","min":-100,"param":"tradeDate=<0>","max":100,"referenceParam":3}],"sourceName":"http://vip.newapi.wmcloud.com/v1/api/market/","targetDateIsVesc":false}


