#!/usr/bin/env node

const Ajv = require('ajv')
const axios = require('axios')

function loadSchema (uri) {
  return axios.get(uri)
    .then((response) => response.data)
}

function ValidationException (data, errors) {
  const error = new Error('Validation exception')
  error.name = 'ValidationException'
  error.data = data
  error.errors = errors
  return error
}

async function createValidatorAsync (schema) {
  const ajv = new Ajv({
    loadSchema
  })

  const validate = await ajv.compileAsync(schema)

  return function (data) {
    const valid = validate(data)
    if (!valid) {
      throw new ValidationException(data, validate.errors)
    }

    return true
  }
}

async function createValidator (schemaId, schemas) {
  const ajv = new Ajv({schemas})

  const validate = ajv.getSchema(schemaId)

  if (!validate) {
    throw new Error(`Can't find schema with ID ${schemaId}`)
  }

  return function (data) {
    const valid = validate(data)
    if (!valid) {
      throw new ValidationException(data, validate.errors)
    }

    return true
  }
}

module.exports = {
  createValidatorAsync,
  createValidator
}
