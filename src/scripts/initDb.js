/* eslint-disable no-console */
const fs = require('fs/promises');
const path = require('path');

const { pool } = require('../config/db');

async function readSchemaFile() {
  const schemaPath = path.resolve(__dirname, 'schema.sql');
  try {
    const contents = await fs.readFile(schemaPath, 'utf8');
    return contents;
  } catch (error) {
    throw new Error(`Unable to read schema.sql at ${schemaPath}: ${error.message}`);
  }
}

function splitStatements(sql) {
  return sql
    .split(/;\s*(?:\r?\n|$)/)
    .map((statement) => statement.trim())
    .filter(Boolean);
}

async function run() {
  console.log('Starting database initialization...');
  const schema = await readSchemaFile();
  const statements = splitStatements(schema);

  if (!statements.length) {
    console.warn('No SQL statements detected in schema.sql.');
    return;
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    for (const statement of statements) {
      console.log(`Executing: ${statement.slice(0, 80)}...`);
      await connection.query(statement);
    }

    await connection.commit();
    console.log('Database initialization completed successfully.');
  } catch (error) {
    await connection.rollback();
    console.error('Database initialization failed, changes rolled back.');
    throw error;
  } finally {
    connection.release();
    await pool.end();
  }
}

run()
  .then(() => {
    console.log('initDb script finished.');
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
