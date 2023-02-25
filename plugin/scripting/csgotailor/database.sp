#if defined _CSGOTAILOR_DATABASE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_DATABASE_INCLUDED

void Setup_Database() {
  char configName[64];
  char error[MAX_ERROR_SIZE];
  g_ConVar_DatabaseConfigName.GetString(configName, sizeof(configName));

  g_database = SQL_Connect(configName, true, error, sizeof(error));

  if (g_database == null) {
    ThrowError("Failed to connect to database. (%s)", error);
  }

  DB_MakeTables();
}

DBStatement DB_Query(char[] query) {
  char dbError[MAX_ERROR_SIZE];
  DBStatement stmt = SQL_PrepareQuery(g_database, query, dbError, sizeof(dbError));

  if (stmt == null) {
    ThrowError("CSGOTailor Database Error: %s", dbError);
  }

  return stmt;
}

void DB_BindString(DBStatement stmt, int column, char[] value) {
  SQL_BindParamString(stmt, column, value, false);
}

void DB_BindInt(DBStatement stmt, int column, int value) {
  SQL_BindParamInt(stmt, column, value, false);
}

void DB_BindFloat(DBStatement stmt, int column, float value) {
  SQL_BindParamFloat(stmt, column, value);
}

void DB_FetchString(DBStatement stmt, int column, char[] buffer, int bufferSize) {
  SQL_FetchString(stmt, column, buffer, bufferSize);
}

int DB_FetchInt(DBStatement stmt, int column) {
  return SQL_FetchInt(stmt, column);
}

float DB_FetchFloat(DBStatement stmt, int column) {
  return SQL_FetchFloat(stmt, column);
}

bool DB_Execute(DBStatement stmt) {
  if (!SQL_Execute(stmt)) {
    char dbError[MAX_ERROR_SIZE];
    SQL_GetError(g_database, dbError, sizeof(dbError));
    ThrowError("CSGOTailor Database Error: %s", dbError);
    return false;
  }
  return true;
}

void DB_FastQuery(char[] query) {
  if (!SQL_FastQuery(g_database, query)) {
    char error[MAX_ERROR_SIZE];
    SQL_GetError(g_database, error, sizeof(error));
    ThrowError("CSGOTailor Database Error: %s", error);
  }
}

void DB_MakeTables() {
  DB_FastQuery("\
  CREATE TABLE IF NOT EXISTS csgotailor_weapons \
  ( \
    steamId         varchar(128)              not null, \
    team            varchar(2)                not null, \
    classname       varchar(128)              not null, \
    paint           varchar(128)              not null, \
    wear            float(12)                 not null, \
    seed            int                       not null, \
    stattrak        tinyint(1)                not null, \
    stattrakCount   int                       not null, \
    nametag         varchar(128)              not null, \
    stickers        varchar(512)              not null, \
    UNIQUE KEY `csgotailor_skins_unique_key` (`steamId`, `team`, `classname`) \
  );");

  DB_FastQuery("\
  CREATE TABLE IF NOT EXISTS csgotailor_knifes \
  ( \
    steamId         varchar(128)              not null, \
    team            varchar(2)                not null, \
    classname       varchar(128)              not null, \
    paint           varchar(128)              not null, \
    wear            float(12)                 not null, \
    seed            int                       not null, \
    stattrak        tinyint(1)                not null, \
    stattrakCount   int                       not null, \
    nametag         varchar(128)              not null, \
    UNIQUE KEY `csgotailor_knifes_unique_key` (`steamId`, `team`) \
  );");

  DB_FastQuery("\
  CREATE TABLE IF NOT EXISTS csgotailor_gloves \
  ( \
    steamId       varchar(128)              not null, \
    team          varchar(2)                not null, \
    classname     varchar(128)              not null, \
    paint         varchar(128)              not null, \
    wear          float(12)                 not null, \
    seed          int                       not null, \
    UNIQUE KEY `csgotailor_gloves_unique_key` (`steamId`, `team`) \
  );");
}
