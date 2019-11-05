#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
const util = require('util')
const { promisify } = require('util')
const glob = promisify(require('glob'))
const jsonpath = require('jsonpath')

const validate = require('../validate')

function readJSONFile (filename) {
  try {
    return {
      filename,
      ...JSON.parse(fs.readFileSync(filename, 'utf8'))
    }
  } catch (err) {
    throw new Error(`Error reading JSON file: ${filename}`)
  }
}

async function readJSONFiles (pattern) {
  const filenames = await glob(pattern)
  return filenames.map(readJSONFile)
}

function runTest (validator, test) {
  try {
    const result = validator(test.data)

    if (result && test.errors && test.errors.length) {
      console.error(test.filename)
      console.error('Expecting errors:')
      console.error(test.errors)
      return false
    }

    return result
  } catch (err) {
    if (!test.errors || !test.errors.length) {
      console.error(test.filename)
      console.error('Validation errors:')
      console.log(util.inspect(err.errors, false, null, true))
      return false
    }

    const result = test.errors.every((error) => {
      const value = jsonpath.value(err.errors, error.path)
      return value === error.value
    })

    if (!result) {
      console.error(test.filename)
      console.error('Validation errors:')
      console.error(err.errors)
      console.error('Expecting errors:')
      console.error(test.errors)
      return false
    } else {
      return true
    }
  }
}

async function runAllTests () {
  const schemas = [
    readJSONFile(path.join(__dirname, '..', 'geojson', 'Geometry.json')),
    readJSONFile(path.join(__dirname, '..', 'schema.json')),
    ...await readJSONFiles(path.join(__dirname, '..', 'meta/*.json'))
  ]

  const validator = await validate.createValidator('https://ams-schema.glitch.me/schema@v0.1#', schemas)

  const tests = await readJSONFiles(path.join(__dirname, '**/*.json'))

  const results = tests.every((test) => runTest(validator, test))
  process.exit(results ? 0 : 1)
}

(() => {
  try {
    runAllTests()
  } catch (err) {
    console.error(err.message)
  }
})()
