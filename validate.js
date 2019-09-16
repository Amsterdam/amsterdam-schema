#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
const Ajv = require('ajv')
const axios = require('axios')

// const H = require('highland')
// const argv = require('yargs')
//   .option('schemas', {
//     alias: 's',
//     type: 'array',
//     describe: 'JSON Schemas to use (relative paths)'
//   })
//   .option('id', {
//     alias: 'i',
//     type: 'string',
//     describe: '$id of schema to use for validation'
//   })
//   .demandOption(['id', 'schemas'], 'Please provide both id and schemas arguments')
//   .argv

// const Validate = require('./lib/validate')

function loadSchema (uri) {
  return axios.get(uri)
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

  return function (data) {
    const valid = validate(data)
    if (!valid) {
      throw new ValidationException(data, validate.errors)
    }

    return true
  }
}

if (process.stdin.isTTY) {
  // return console.error(`Usage: ${name} [-f jsonPaths] [-o file] FILE\n` +
  //   `  -f, --flatten  JSON array of JSON paths, used to flatten nested data field\n` +
  //   `  -o, --output   Path to output file, if not given, ${name} uses stdout`)

  // const stream = ((argv._.length ? fs.createReadStream(argv._[0], 'utf8') : process.stdin))

  // const schemas = argv.schemas
  //   .map((schemaPath) => JSON.parse(fs.readFileSync(path.join('.', schemaPath), 'utf8')))

  // const validate = Validate.createValidator(argv.id, schemas)

  // H(process.stdin)
  //   .split()
  //   .compact()
  //   .map(JSON.parse)
  //   .map((object) => validate(object))
  //   .errors((err, push) => {
  //     if (err.name === 'ValidationException') {
  //       let id
  //       if (err.data.$id) {
  //         id = err.data.$id
  //       } else {
  //         id = `${err.data.type}:${err.data.id}`
  //       }

  //       console.error(`Errors validating ${id}:`)
  //       console.error(err.errors)
  //     } else {
  //       console.error({
  //         name: err.name,
  //         message: err.message
  //       })
  //     }
  //   })
  //   .compact()
  //   .map(JSON.stringify)
  //   .intersperse('\n')
  //   .pipe(process.stdout)
}

module.exports = {
  createValidatorAsync,
  createValidator
}
