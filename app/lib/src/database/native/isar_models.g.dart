// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarRecordingSessionCollection on Isar {
  IsarCollection<IsarRecordingSession> get isarRecordingSessions =>
      this.collection();
}

const IsarRecordingSessionSchema = CollectionSchema(
  name: r'IsarRecordingSession',
  id: 1845619147111387131,
  properties: {
    r'note': PropertySchema(
      id: 0,
      name: r'note',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 1,
      name: r'startTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _isarRecordingSessionEstimateSize,
  serialize: _isarRecordingSessionSerialize,
  deserialize: _isarRecordingSessionDeserialize,
  deserializeProp: _isarRecordingSessionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarRecordingSessionGetId,
  getLinks: _isarRecordingSessionGetLinks,
  attach: _isarRecordingSessionAttach,
  version: '3.1.0+1',
);

int _isarRecordingSessionEstimateSize(
  IsarRecordingSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarRecordingSessionSerialize(
  IsarRecordingSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.note);
  writer.writeDateTime(offsets[1], object.startTime);
}

IsarRecordingSession _isarRecordingSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarRecordingSession();
  object.id = id;
  object.note = reader.readStringOrNull(offsets[0]);
  object.startTime = reader.readDateTime(offsets[1]);
  return object;
}

P _isarRecordingSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarRecordingSessionGetId(IsarRecordingSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarRecordingSessionGetLinks(
    IsarRecordingSession object) {
  return [];
}

void _isarRecordingSessionAttach(
    IsarCollection<dynamic> col, Id id, IsarRecordingSession object) {
  object.id = id;
}

extension IsarRecordingSessionQueryWhereSort
    on QueryBuilder<IsarRecordingSession, IsarRecordingSession, QWhere> {
  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarRecordingSessionQueryWhere
    on QueryBuilder<IsarRecordingSession, IsarRecordingSession, QWhereClause> {
  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarRecordingSessionQueryFilter on QueryBuilder<IsarRecordingSession,
    IsarRecordingSession, QFilterCondition> {
  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
          QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
          QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession,
      QAfterFilterCondition> startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarRecordingSessionQueryObject on QueryBuilder<IsarRecordingSession,
    IsarRecordingSession, QFilterCondition> {}

extension IsarRecordingSessionQueryLinks on QueryBuilder<IsarRecordingSession,
    IsarRecordingSession, QFilterCondition> {}

extension IsarRecordingSessionQuerySortBy
    on QueryBuilder<IsarRecordingSession, IsarRecordingSession, QSortBy> {
  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension IsarRecordingSessionQuerySortThenBy
    on QueryBuilder<IsarRecordingSession, IsarRecordingSession, QSortThenBy> {
  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension IsarRecordingSessionQueryWhereDistinct
    on QueryBuilder<IsarRecordingSession, IsarRecordingSession, QDistinct> {
  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QDistinct>
      distinctByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRecordingSession, IsarRecordingSession, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension IsarRecordingSessionQueryProperty on QueryBuilder<
    IsarRecordingSession, IsarRecordingSession, QQueryProperty> {
  QueryBuilder<IsarRecordingSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarRecordingSession, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<IsarRecordingSession, DateTime, QQueryOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarTemperatureReadingCollection on Isar {
  IsarCollection<IsarTemperatureReading> get isarTemperatureReadings =>
      this.collection();
}

const IsarTemperatureReadingSchema = CollectionSchema(
  name: r'IsarTemperatureReading',
  id: -4013240181148862774,
  properties: {
    r'sessionId': PropertySchema(
      id: 0,
      name: r'sessionId',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 1,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'value': PropertySchema(
      id: 2,
      name: r'value',
      type: IsarType.double,
    )
  },
  estimateSize: _isarTemperatureReadingEstimateSize,
  serialize: _isarTemperatureReadingSerialize,
  deserialize: _isarTemperatureReadingDeserialize,
  deserializeProp: _isarTemperatureReadingDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId_timestamp': IndexSchema(
      id: 3954140302816288673,
      name: r'sessionId_timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarTemperatureReadingGetId,
  getLinks: _isarTemperatureReadingGetLinks,
  attach: _isarTemperatureReadingAttach,
  version: '3.1.0+1',
);

int _isarTemperatureReadingEstimateSize(
  IsarTemperatureReading object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _isarTemperatureReadingSerialize(
  IsarTemperatureReading object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.sessionId);
  writer.writeDateTime(offsets[1], object.timestamp);
  writer.writeDouble(offsets[2], object.value);
}

IsarTemperatureReading _isarTemperatureReadingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarTemperatureReading();
  object.id = id;
  object.sessionId = reader.readLong(offsets[0]);
  object.timestamp = reader.readDateTime(offsets[1]);
  object.value = reader.readDouble(offsets[2]);
  return object;
}

P _isarTemperatureReadingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarTemperatureReadingGetId(IsarTemperatureReading object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarTemperatureReadingGetLinks(
    IsarTemperatureReading object) {
  return [];
}

void _isarTemperatureReadingAttach(
    IsarCollection<dynamic> col, Id id, IsarTemperatureReading object) {
  object.id = id;
}

extension IsarTemperatureReadingQueryWhereSort
    on QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QWhere> {
  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterWhere>
      anySessionIdTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionId_timestamp'),
      );
    });
  }
}

extension IsarTemperatureReadingQueryWhere on QueryBuilder<
    IsarTemperatureReading, IsarTemperatureReading, QWhereClause> {
  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> sessionIdEqualToAnyTimestamp(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId_timestamp',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> sessionIdNotEqualToAnyTimestamp(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> sessionIdGreaterThanAnyTimestamp(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [sessionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> sessionIdLessThanAnyTimestamp(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [],
        upper: [sessionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> sessionIdBetweenAnyTimestamp(
    int lowerSessionId,
    int upperSessionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [lowerSessionId],
        includeLower: includeLower,
        upper: [upperSessionId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
          QAfterWhereClause>
      sessionIdTimestampEqualTo(int sessionId, DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId_timestamp',
        value: [sessionId, timestamp],
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
          QAfterWhereClause>
      sessionIdEqualToTimestampNotEqualTo(int sessionId, DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId],
              upper: [sessionId, timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId, timestamp],
              includeLower: false,
              upper: [sessionId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId, timestamp],
              includeLower: false,
              upper: [sessionId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId],
              upper: [sessionId, timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> sessionIdEqualToTimestampGreaterThan(
    int sessionId,
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [sessionId, timestamp],
        includeLower: include,
        upper: [sessionId],
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> sessionIdEqualToTimestampLessThan(
    int sessionId,
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [sessionId],
        upper: [sessionId, timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterWhereClause> sessionIdEqualToTimestampBetween(
    int sessionId,
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [sessionId, lowerTimestamp],
        includeLower: includeLower,
        upper: [sessionId, upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarTemperatureReadingQueryFilter on QueryBuilder<
    IsarTemperatureReading, IsarTemperatureReading, QFilterCondition> {
  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> sessionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> sessionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> sessionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> sessionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> valueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> valueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> valueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading,
      QAfterFilterCondition> valueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension IsarTemperatureReadingQueryObject on QueryBuilder<
    IsarTemperatureReading, IsarTemperatureReading, QFilterCondition> {}

extension IsarTemperatureReadingQueryLinks on QueryBuilder<
    IsarTemperatureReading, IsarTemperatureReading, QFilterCondition> {}

extension IsarTemperatureReadingQuerySortBy
    on QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QSortBy> {
  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension IsarTemperatureReadingQuerySortThenBy on QueryBuilder<
    IsarTemperatureReading, IsarTemperatureReading, QSortThenBy> {
  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QAfterSortBy>
      thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension IsarTemperatureReadingQueryWhereDistinct
    on QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QDistinct> {
  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QDistinct>
      distinctBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId');
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<IsarTemperatureReading, IsarTemperatureReading, QDistinct>
      distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value');
    });
  }
}

extension IsarTemperatureReadingQueryProperty on QueryBuilder<
    IsarTemperatureReading, IsarTemperatureReading, QQueryProperty> {
  QueryBuilder<IsarTemperatureReading, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarTemperatureReading, int, QQueryOperations>
      sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<IsarTemperatureReading, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<IsarTemperatureReading, double, QQueryOperations>
      valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarSessionMarkerCollection on Isar {
  IsarCollection<IsarSessionMarker> get isarSessionMarkers => this.collection();
}

const IsarSessionMarkerSchema = CollectionSchema(
  name: r'IsarSessionMarker',
  id: -6528117166660074297,
  properties: {
    r'label': PropertySchema(
      id: 0,
      name: r'label',
      type: IsarType.string,
    ),
    r'sessionId': PropertySchema(
      id: 1,
      name: r'sessionId',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _isarSessionMarkerEstimateSize,
  serialize: _isarSessionMarkerSerialize,
  deserialize: _isarSessionMarkerDeserialize,
  deserializeProp: _isarSessionMarkerDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId_timestamp': IndexSchema(
      id: 3954140302816288673,
      name: r'sessionId_timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarSessionMarkerGetId,
  getLinks: _isarSessionMarkerGetLinks,
  attach: _isarSessionMarkerAttach,
  version: '3.1.0+1',
);

int _isarSessionMarkerEstimateSize(
  IsarSessionMarker object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.label.length * 3;
  return bytesCount;
}

void _isarSessionMarkerSerialize(
  IsarSessionMarker object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.label);
  writer.writeLong(offsets[1], object.sessionId);
  writer.writeDateTime(offsets[2], object.timestamp);
}

IsarSessionMarker _isarSessionMarkerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarSessionMarker();
  object.id = id;
  object.label = reader.readString(offsets[0]);
  object.sessionId = reader.readLong(offsets[1]);
  object.timestamp = reader.readDateTime(offsets[2]);
  return object;
}

P _isarSessionMarkerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarSessionMarkerGetId(IsarSessionMarker object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarSessionMarkerGetLinks(
    IsarSessionMarker object) {
  return [];
}

void _isarSessionMarkerAttach(
    IsarCollection<dynamic> col, Id id, IsarSessionMarker object) {
  object.id = id;
}

extension IsarSessionMarkerQueryWhereSort
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QWhere> {
  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhere>
      anySessionIdTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionId_timestamp'),
      );
    });
  }
}

extension IsarSessionMarkerQueryWhere
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QWhereClause> {
  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdEqualToAnyTimestamp(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId_timestamp',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdNotEqualToAnyTimestamp(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdGreaterThanAnyTimestamp(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [sessionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdLessThanAnyTimestamp(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [],
        upper: [sessionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdBetweenAnyTimestamp(
    int lowerSessionId,
    int upperSessionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [lowerSessionId],
        includeLower: includeLower,
        upper: [upperSessionId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdTimestampEqualTo(int sessionId, DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId_timestamp',
        value: [sessionId, timestamp],
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdEqualToTimestampNotEqualTo(int sessionId, DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId],
              upper: [sessionId, timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId, timestamp],
              includeLower: false,
              upper: [sessionId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId, timestamp],
              includeLower: false,
              upper: [sessionId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId_timestamp',
              lower: [sessionId],
              upper: [sessionId, timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdEqualToTimestampGreaterThan(
    int sessionId,
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [sessionId, timestamp],
        includeLower: include,
        upper: [sessionId],
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdEqualToTimestampLessThan(
    int sessionId,
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [sessionId],
        upper: [sessionId, timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterWhereClause>
      sessionIdEqualToTimestampBetween(
    int sessionId,
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId_timestamp',
        lower: [sessionId, lowerTimestamp],
        includeLower: includeLower,
        upper: [sessionId, upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarSessionMarkerQueryFilter
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QFilterCondition> {
  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      sessionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      sessionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      sessionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      sessionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarSessionMarkerQueryObject
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QFilterCondition> {}

extension IsarSessionMarkerQueryLinks
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QFilterCondition> {}

extension IsarSessionMarkerQuerySortBy
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QSortBy> {
  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension IsarSessionMarkerQuerySortThenBy
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QSortThenBy> {
  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension IsarSessionMarkerQueryWhereDistinct
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QDistinct> {
  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QDistinct>
      distinctBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId');
    });
  }

  QueryBuilder<IsarSessionMarker, IsarSessionMarker, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension IsarSessionMarkerQueryProperty
    on QueryBuilder<IsarSessionMarker, IsarSessionMarker, QQueryProperty> {
  QueryBuilder<IsarSessionMarker, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarSessionMarker, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<IsarSessionMarker, int, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<IsarSessionMarker, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
