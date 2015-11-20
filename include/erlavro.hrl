-ifndef(_ERLAVRO_HRL_).
-define(_ERLAVRO_HRL_, true).

%% Names of primitive types
-define(AVRO_NULL,    "null").
-define(AVRO_BOOLEAN, "boolean").
-define(AVRO_INT,     "int").
-define(AVRO_LONG,    "long").
-define(AVRO_FLOAT,   "float").
-define(AVRO_DOUBLE,  "double").
-define(AVRO_BYTES,   "bytes").
-define(AVRO_STRING,  "string").

%% Other reserved types names
-define(AVRO_RECORD,  "record").
-define(AVRO_ENUM,    "enum").
-define(AVRO_ARRAY,   "array").
-define(AVRO_MAP,     "map").
-define(AVRO_UNION,   "union").
-define(AVRO_FIXED,   "fixed").

-define(INT4_MIN, -2147483648).
-define(INT4_MAX,  2147483647).

-define(INT8_MIN, -9223372036854775808).
-define(INT8_MAX,  9223372036854775807).

-define(REQUIRED, =erlang:error({required_field_missed, ?MODULE, ?LINE})).

-type avro_ordering() :: ascending | descending | ignore.

%% Information about service fields:
%% 'fullname' contains qualified full name of the type.
%% Should always present, a type without fullname can't be considered as valid.

-record(avro_record_field,
        { name      ?REQUIRED :: string()
        , doc       = ""      :: string()
        , type      ?REQUIRED :: avro_type_or_name()
        , default             :: avro_value() | undefined
        , order  = ascending  :: avro_ordering()
        , aliases   = []      :: [string()]
        }).

%% fullname of a primitive types is always equal to its name
-record(avro_primitive_type,
        { name      ?REQUIRED :: string()
        }).

-record(avro_record_type,
        { name      ?REQUIRED :: string()
        , namespace = ""      :: string()
        , doc       = ""      :: string()
        , aliases   = []      :: [string()]
        , fields    ?REQUIRED :: [#avro_record_field{}]
        %% -- service fields --
        , fullname  ?REQUIRED :: string()
        }).

-record(avro_enum_type,
        { name      ?REQUIRED :: string()
        , namespace = ""      :: string()
        , aliases   = []      :: [string()]
        , doc       = ""      :: string()
        , symbols   ?REQUIRED :: [string()]
        %% -- service fields --
        , fullname  ?REQUIRED :: string()
        }).

-record(avro_array_type,
        { type      ?REQUIRED :: avro_type_or_name()
        }).

-record(avro_map_type,
        { type      ?REQUIRED :: avro_type_or_name()
        }).

-ifndef(otp_17_or_above).
-type avro_types_dict() :: undefined | dict(). %% string() -> avro_type()
-else.
-type avro_types_dict() :: undefined | dict:dict(string(), avro_type()).
-endif.

-record(avro_union_type,
        { types     ?REQUIRED :: [avro_type_or_name()]
          %% Precached dictionary of types inside the union,
          %% helps to speed up types lookups for big unions.
          %% Dictionary is filled only for big unions (>10)
          %% when dictionary lookup is more efficient than
          %% sequential scan, so it is normal if the dictionary
          %% is set to undefined.
        , types_dict          :: avro_types_dict()
        }).

-record(avro_fixed_type,
        { name      ?REQUIRED :: string()
        , namespace = ""      :: string()
        , aliases   = []      :: [string()]
        , size      ?REQUIRED :: integer()
        %% -- service fields --
        , fullname  ?REQUIRED :: string()
        }).

-record(avro_value,
        { type :: avro_type()
        , data :: term()
        }).

-type avro_type()  :: #avro_primitive_type{} |
                      #avro_record_type{} |
                      #avro_enum_type{}   |
                      #avro_array_type{}  |
                      #avro_map_type{}    |
                      #avro_union_type{}  |
                      #avro_fixed_type{}.

-type avro_type_or_name() :: avro_type() | string().

-type avro_value() :: #avro_value{}.

-define(IS_AVRO_VALUE(Value), is_record(Value, avro_value)).
-define(AVRO_VALUE(Type,Data), #avro_value{type = Type, data = Data}).
-define(AVRO_VALUE_TYPE(Value), Value#avro_value.type).
-define(AVRO_VALUE_DATA(Value), Value#avro_value.data).

-define(AVRO_UPDATE_VALUE(Value,Data), Value#avro_value{data = Data}).

%% Type checks

-define(AVRO_IS_PRIMITIVE_TYPE(Type), is_record(Type, avro_primitive_type)).

-define(AVRO_IS_NULL_TYPE(Type),
        ?AVRO_IS_PRIMITIVE_TYPE(Type) andalso
        Type#avro_primitive_type.name =:= ?AVRO_NULL).

-define(AVRO_IS_BOOLEAN_TYPE(Type),
        ?AVRO_IS_PRIMITIVE_TYPE(Type) andalso
        Type#avro_primitive_type.name =:= ?AVRO_BOOLEAN).

-define(AVRO_IS_INT_TYPE(Type),
        ?AVRO_IS_PRIMITIVE_TYPE(Type) andalso
        Type#avro_primitive_type.name =:= ?AVRO_INT).

-define(AVRO_IS_LONG_TYPE(Type),
        ?AVRO_IS_PRIMITIVE_TYPE(Type) andalso
        Type#avro_primitive_type.name =:= ?AVRO_LONG).

-define(AVRO_IS_FLOAT_TYPE(Type),
        ?AVRO_IS_PRIMITIVE_TYPE(Type) andalso
        Type#avro_primitive_type.name =:= ?AVRO_FLOAT).

-define(AVRO_IS_DOUBLE_TYPE(Type),
        ?AVRO_IS_PRIMITIVE_TYPE(Type) andalso
        Type#avro_primitive_type.name =:= ?AVRO_DOUBLE).

-define(AVRO_IS_BYTES_TYPE(Type),
        ?AVRO_IS_PRIMITIVE_TYPE(Type) andalso
        Type#avro_primitive_type.name =:= ?AVRO_BYTES).

-define(AVRO_IS_STRING_TYPE(Type),
        ?AVRO_IS_PRIMITIVE_TYPE(Type) andalso
        Type#avro_primitive_type.name =:= ?AVRO_STRING).

-define(AVRO_IS_RECORD_TYPE(Type), is_record(Type, avro_record_type)).

-define(AVRO_IS_ENUM_TYPE(Type), is_record(Type, avro_enum_type)).

-define(AVRO_IS_ARRAY_TYPE(Type), is_record(Type, avro_array_type)).

-define(AVRO_IS_MAP_TYPE(Type), is_record(Type, avro_map_type)).

-define(AVRO_IS_UNION_TYPE(Type), is_record(Type, avro_union_type)).

-define(AVRO_IS_FIXED_TYPE(Type), is_record(Type, avro_fixed_type)).

%% Values checks

-define(AVRO_IS_NULL_VALUE(Value), ?AVRO_IS_NULL_TYPE(
                                      ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_BOOLEAN_VALUE(Value), ?AVRO_IS_BOOLEAN_TYPE(
                                         ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_INT_VALUE(Value), ?AVRO_IS_INT_TYPE(
                                     ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_LONG_VALUE(Value), ?AVRO_IS_LONG_TYPE(
                                      ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_FLOAT_VALUE(Value), ?AVRO_IS_FLOAT_TYPE(
                                       ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_DOUBLE_VALUE(Value), ?AVRO_IS_DOUBLE_TYPE(
                                        ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_BYTES_VALUE(Value), ?AVRO_IS_BYTES_TYPE(
                                       ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_STRING_VALUE(Value), ?AVRO_IS_STRING_TYPE(
                                        ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_RECORD_VALUE(Value), ?AVRO_IS_RECORD_TYPE(
                                        ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_ENUM_VALUE(Value), ?AVRO_IS_ENUM_TYPE(
                                      ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_ARRAY_VALUE(Value), ?AVRO_IS_ARRAY_TYPE(
                                       ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_MAP_VALUE(Value), ?AVRO_IS_MAP_TYPE(
                                     ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_UNION_VALUE(Value), ?AVRO_IS_UNION_TYPE(
                                       ?AVRO_VALUE_TYPE(Value))).

-define(AVRO_IS_FIXED_VALUE(Value), ?AVRO_IS_FIXED_TYPE(
                                       ?AVRO_VALUE_TYPE(Value))).

%% Service macroses
-define(ERROR_IF(Cond, Err),
        case Cond of
            true  -> erlang:error(Err);
            false -> ok
        end).

-define(ERROR_IF_NOT(Cond, Err), ?ERROR_IF(not (Cond), Err)).

-type avro_encoding() :: json_binary.

-define(AVRO_ENCODED_VALUE_JSON(Type, Value), ?AVRO_VALUE(Type, {json, Value})).

%% avro_encoded_value() can be used as a nested inner value of
%% a parent avor_value(), but can not be used for further update or
%% inspection using APIs in avro_xxx modules.
-type avro_encoded_value() :: #avro_value{}.

%% Throw an exception in case the value is already encoded.
-define(ASSERT_AVRO_VALUE(VALUE),
        case VALUE of
          {json, _} -> erlang:throw({value_already_encoded, VALUE});
          _         -> ok
        end).

-endif.
