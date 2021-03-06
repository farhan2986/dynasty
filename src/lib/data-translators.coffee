_ = require('lodash')
util = require('util')

###
   converts a DynamoDB compatible JSON object into
   a native JSON object
   @param dbObj the dynamodb JSON object
   @throws an error if input object is not compatible
   @return res the converted object
###

convertObject = (obj) ->
  converted = {}
  converted[key] = fromDynamo(value) for key, value of obj
  converted

fromDynamo = (dbObj) ->
  if _.isArray dbObj
    obj = []
    for element, key in dbObj
      obj[key] = fromDynamo element
    return obj
  if _.isObject dbObj
    if dbObj.M
      return convertObject(dbObj.M)
    else if(dbObj.BOOL?)
      return dbObj.BOOL
    else if(dbObj.S)
      return dbObj.S
    else if(dbObj.SS)
      return dbObj.SS
    else if(dbObj.N?)
      return parseFloat(dbObj.N)
    else if(dbObj.NS)
      return _.map(dbObj.NS, parseFloat)
    else if(dbObj.L)
      return _.map(dbObj.L, fromDynamo)
    else if(dbObj.NULL)
      return null
    else
      return convertObject(dbObj)
  else
    return dbObj

module.exports.fromDynamo = fromDynamo

# See http://vq.io/19EiASB
toDynamo = (item) ->
  if _.isArray item
    array = []
    for value in item
      array.push(toDynamo(value))
    obj =
      'L': array
  else if _.isNumber item
    obj =
      'N': item.toString()
  else if _.isString item
    obj =
      'S': item
  else if _.isBoolean item
    obj =
      'BOOL': item
  else if _.isObject item
    map = {}
    for key, value of item
      map[key] = toDynamo(value)
    obj =
      'M': map
  else if item is null
    obj =
      'NULL': true
  else if not item
    throw new TypeError "toDynamo() does not support mapping #{util.inspect(item)}"

module.exports.toDynamo = toDynamo
