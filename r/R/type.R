# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

#' @include arrow-package.R
#' @title class arrow::DataType
#'
#' @usage NULL
#' @format NULL
#' @docType class
#'
#' @section Methods:
#'
#' TODO
#'
#' @rdname DataType
#' @name DataType
DataType <- R6Class("DataType",
  inherit = ArrowObject,
  public = list(
    ToString = function() {
      DataType__ToString(self)
    },
    Equals = function(other, ...) {
      inherits(other, "DataType") && DataType__Equals(self, other)
    },
    fields = function() {
      DataType__fields(self)
    },
    export_to_c = function(ptr) ExportType(self, ptr)
  ),
  active = list(
    id = function() DataType__id(self),
    name = function() DataType__name(self),
    num_fields = function() DataType__num_fields(self)
  )
)

#' @include arrowExports.R
DataType$import_from_c <- ImportType

INTEGER_TYPES <- as.character(outer(c("uint", "int"), c(8, 16, 32, 64), paste0))
FLOAT_TYPES <- c("float16", "float32", "float64", "halffloat", "float", "double")

#' infer the arrow Array type from an R vector
#'
#' @param x an R vector
#'
#' @return an arrow logical type
#' @examplesIf arrow_available()
#' type(1:10)
#' type(1L:10L)
#' type(c(1, 1.5, 2))
#' type(c("A", "B", "C"))
#' type(mtcars)
#' type(Sys.Date())
#' @export
type <- function(x) UseMethod("type")

#' @export
type.default <- function(x) Array__infer_type(x)

#' @export
type.ArrowDatum <- function(x) x$type

#----- metadata

#' @title class arrow::FixedWidthType
#'
#' @usage NULL
#' @format NULL
#' @docType class
#'
#' @section Methods:
#'
#' TODO
#'
#' @rdname FixedWidthType
#' @name FixedWidthType
FixedWidthType <- R6Class("FixedWidthType",
  inherit = DataType,
  active = list(
    bit_width = function() FixedWidthType__bit_width(self)
  )
)

Int8 <- R6Class("Int8", inherit = FixedWidthType)
Int16 <- R6Class("Int16", inherit = FixedWidthType)
Int32 <- R6Class("Int32", inherit = FixedWidthType)
Int64 <- R6Class("Int64", inherit = FixedWidthType)
UInt8 <- R6Class("UInt8", inherit = FixedWidthType)
UInt16 <- R6Class("UInt16", inherit = FixedWidthType)
UInt32 <- R6Class("UInt32", inherit = FixedWidthType)
UInt64 <- R6Class("UInt64", inherit = FixedWidthType)
Float16 <- R6Class("Float16", inherit = FixedWidthType)
Float32 <- R6Class("Float32", inherit = FixedWidthType)
Float64 <- R6Class("Float64", inherit = FixedWidthType)
Boolean <- R6Class("Boolean", inherit = FixedWidthType)
Utf8 <- R6Class("Utf8", inherit = DataType)
LargeUtf8 <- R6Class("LargeUtf8", inherit = DataType)
Binary <- R6Class("Binary", inherit = DataType)
FixedSizeBinary <- R6Class("FixedSizeBinary", inherit = FixedWidthType)
LargeBinary <- R6Class("LargeBinary", inherit = DataType)

DateType <- R6Class("DateType",
  inherit = FixedWidthType,
  public = list(
    unit = function() DateType__unit(self)
  )
)
Date32 <- R6Class("Date32", inherit = DateType)
Date64 <- R6Class("Date64", inherit = DateType)

TimeType <- R6Class("TimeType",
  inherit = FixedWidthType,
  public = list(
    unit = function() TimeType__unit(self)
  )
)
Time32 <- R6Class("Time32", inherit = TimeType)
Time64 <- R6Class("Time64", inherit = TimeType)

DurationType <- R6Class("DurationType",
  inherit = FixedWidthType,
  public = list(
    unit = function() DurationType__unit(self)
  )
)

Null <- R6Class("Null", inherit = DataType)

Timestamp <- R6Class("Timestamp",
  inherit = FixedWidthType,
  public = list(
    timezone = function() TimestampType__timezone(self),
    unit = function() TimestampType__unit(self)
  )
)

DecimalType <- R6Class("DecimalType",
  inherit = FixedWidthType,
  public = list(
    precision = function() DecimalType__precision(self),
    scale = function() DecimalType__scale(self)
  )
)
Decimal128Type <- R6Class("Decimal128Type", inherit = DecimalType)

NestedType <- R6Class("NestedType", inherit = DataType)

#' Apache Arrow data types
#'
#' These functions create type objects corresponding to Arrow types. Use them
#' when defining a [schema()] or as inputs to other types, like `struct`. Most
#' of these functions don't take arguments, but a few do.
#'
#' A few functions have aliases:
#'
#' * `utf8()` and `string()`
#' * `float16()` and `halffloat()`
#' * `float32()` and `float()`
#' * `bool()` and `boolean()`
#' * When called inside an `arrow` function, such as `schema()` or `cast()`,
#' `double()` also is supported as a way of creating a `float64()`
#'
#' `date32()` creates a datetime type with a "day" unit, like the R `Date`
#' class. `date64()` has a "ms" unit.
#'
#' `uint32` (32 bit unsigned integer), `uint64` (64 bit unsigned integer), and
#' `int64` (64-bit signed integer) types may contain values that exceed the
#' range of R's `integer` type (32-bit signed integer). When these arrow objects
#' are translated to R objects, `uint32` and `uint64` are converted to `double`
#' ("numeric") and `int64` is converted to `bit64::integer64`. For `int64`
#' types, this conversion can be disabled (so that `int64` always yields a
#' `bit64::integer64` object) by setting `options(arrow.int64_downcast =
#' FALSE)`.
#'
#' `decimal128()` creates a `decimal128` type. Arrow decimals are fixed-point
#' decimal numbers encoded as a scalar integer. The `precision` is the number of
#' significant digits that the decimal type can represent; the `scale` is the
#' number of digits after the decimal point. For example, the number 1234.567
#' has a precision of 7 and a scale of 3. Note that `scale` can be negative.
#'
#' As an example, `decimal128(7, 3)` can exactly represent the numbers 1234.567 and
#' -1234.567 (encoded internally as the 128-bit integers 1234567 and -1234567,
#' respectively), but neither 12345.67 nor 123.4567.
#'
#' `decimal128(5, -3)` can exactly represent the number 12345000 (encoded
#' internally as the 128-bit integer 12345), but neither 123450000 nor 1234500.
#' The `scale` can be thought of as an argument that controls rounding. When
#' negative, `scale` causes the number to be expressed using scientific notation
#' and power of 10.
#'
#' `decimal()` is identical to `decimal128()`, defined for backward compatibility.
#' Use `decimal128()` as the name  is more informative and `decimal()` might be
#' deprecated in the future.
#'
#' @param unit For time/timestamp types, the time unit. `time32()` can take
#' either "s" or "ms", while `time64()` can be "us" or "ns". `timestamp()` can
#' take any of those four values.
#' @param timezone For `timestamp()`, an optional time zone string.
#' @param byte_width byte width for `FixedSizeBinary` type.
#' @param list_size list size for `FixedSizeList` type.
#' @param precision For `decimal()`, `decimal128()` the number of significant
#'    digits the arrow `decimal` type can represent. The maximum precision for
#'    `decimal()` and `decimal128()` is 38 significant digits.
#' @param scale For `decimal()` and `decimal128()`, the number of digits after
#'    the decimal point. It can be negative.
#' @param type For `list_of()`, a data type to make a list-of-type
#' @param ... For `struct()`, a named list of types to define the struct columns
#'
#' @name data-type
#' @return An Arrow type object inheriting from DataType.
#' @export
#' @seealso [dictionary()] for creating a dictionary (factor-like) type.
#' @examplesIf arrow_available()
#' bool()
#' struct(a = int32(), b = double())
#' timestamp("ms", timezone = "CEST")
#' time64("ns")
int8 <- function() Int8__initialize()

#' @rdname data-type
#' @export
int16 <- function() Int16__initialize()

#' @rdname data-type
#' @export
int32 <- function() Int32__initialize()

#' @rdname data-type
#' @export
int64 <- function() Int64__initialize()

#' @rdname data-type
#' @export
uint8 <- function() UInt8__initialize()

#' @rdname data-type
#' @export
uint16 <- function() UInt16__initialize()

#' @rdname data-type
#' @export
uint32 <- function() UInt32__initialize()

#' @rdname data-type
#' @export
uint64 <- function() UInt64__initialize()

#' @rdname data-type
#' @export
float16 <- function() Float16__initialize()

#' @rdname data-type
#' @export
halffloat <- float16

#' @rdname data-type
#' @export
float32 <- function() Float32__initialize()

#' @rdname data-type
#' @export
float <- float32

#' @rdname data-type
#' @export
float64 <- function() Float64__initialize()

#' @rdname data-type
#' @export
boolean <- function() Boolean__initialize()

#' @rdname data-type
#' @export
bool <- boolean

#' @rdname data-type
#' @export
utf8 <- function() Utf8__initialize()

#' @rdname data-type
#' @export
large_utf8 <- function() LargeUtf8__initialize()

#' @rdname data-type
#' @export
binary <- function() Binary__initialize()

#' @rdname data-type
#' @export
large_binary <- function() LargeBinary__initialize()

#' @rdname data-type
#' @export
fixed_size_binary <- function(byte_width) FixedSizeBinary__initialize(byte_width)

#' @rdname data-type
#' @export
string <- utf8

#' @rdname data-type
#' @export
date32 <- function() Date32__initialize()

#' @rdname data-type
#' @export
date64 <- function() Date64__initialize()

#' @rdname data-type
#' @export
time32 <- function(unit = c("ms", "s")) {
  if (is.character(unit)) {
    unit <- match.arg(unit)
  }
  unit <- make_valid_time_unit(unit, valid_time32_units)
  Time32__initialize(unit)
}

valid_time32_units <- c(
  "ms" = TimeUnit$MILLI,
  "s" = TimeUnit$SECOND
)

valid_time64_units <- c(
  "ns" = TimeUnit$NANO,
  "us" = TimeUnit$MICRO
)

valid_duration_units <- c(
  "s" = TimeUnit$SECOND,
  "ms" = TimeUnit$MILLI,
  "us" = TimeUnit$MICRO,
  "ns" = TimeUnit$NANO
)

make_valid_time_unit <- function(unit, valid_units) {
  if (is.character(unit)) {
    unit <- valid_units[match.arg(unit, choices = names(valid_units))]
  }
  if (is.numeric(unit)) {
    # Allow non-integer input for convenience
    unit <- as.integer(unit)
  } else {
    stop('"unit" should be one of ', oxford_paste(names(valid_units), "or"), call. = FALSE)
  }
  if (!(unit %in% valid_units)) {
    stop('"unit" should be one of ', oxford_paste(valid_units, "or"), call. = FALSE)
  }
  unit
}

#' @rdname data-type
#' @export
time64 <- function(unit = c("ns", "us")) {
  if (is.character(unit)) {
    unit <- match.arg(unit)
  }
  unit <- make_valid_time_unit(unit, valid_time64_units)
  Time64__initialize(unit)
}

#' @rdname data-type
#' @export
duration <- function(unit = c("s", "ms", "us", "ns")) {
  if (is.character(unit)) {
    unit <- match.arg(unit)
  }
  unit <- make_valid_time_unit(unit, valid_duration_units)
  Duration__initialize(unit)
}

#' @rdname data-type
#' @export
null <- function() Null__initialize()

#' @rdname data-type
#' @export
timestamp <- function(unit = c("s", "ms", "us", "ns"), timezone = "") {
  if (is.character(unit)) {
    unit <- match.arg(unit)
  }
  unit <- make_valid_time_unit(unit, c(valid_time64_units, valid_time32_units))
  assert_that(is.string(timezone))
  Timestamp__initialize(unit, timezone)
}

#' @rdname data-type
#' @export
decimal128 <- function(precision, scale) {
  if (is.numeric(precision)) {
    precision <- as.integer(precision)
  } else {
    stop('"precision" must be an integer', call. = FALSE)
  }
  if (is.numeric(scale)) {
    scale <- as.integer(scale)
  } else {
    stop('"scale" must be an integer', call. = FALSE)
  }
  Decimal128Type__initialize(precision, scale)
}

#' @rdname data-type
#' @export
decimal <- decimal128

StructType <- R6Class("StructType",
  inherit = NestedType,
  public = list(
    GetFieldByName = function(name) StructType__GetFieldByName(self, name),
    GetFieldIndex = function(name) StructType__GetFieldIndex(self, name)
  )
)
StructType$create <- function(...) struct__(.fields(list(...)))

#' @rdname data-type
#' @export
struct <- StructType$create

ListType <- R6Class("ListType",
  inherit = NestedType,
  active = list(
    value_field = function() ListType__value_field(self),
    value_type = function() ListType__value_type(self)
  )
)

#' @rdname data-type
#' @export
list_of <- function(type) list__(type)

LargeListType <- R6Class("LargeListType",
  inherit = NestedType,
  active = list(
    value_field = function() LargeListType__value_field(self),
    value_type = function() LargeListType__value_type(self)
  )
)

#' @rdname data-type
#' @export
large_list_of <- function(type) large_list__(type)

#' @rdname data-type
#' @export
FixedSizeListType <- R6Class("FixedSizeListType",
  inherit = NestedType,
  active = list(
    value_field = function() FixedSizeListType__value_field(self),
    value_type = function() FixedSizeListType__value_type(self),
    list_size = function() FixedSizeListType__list_size(self)
  )
)

#' @rdname data-type
#' @export
fixed_size_list_of <- function(type, list_size) fixed_size_list__(type, list_size)

as_type <- function(type, name = "type") {
  # magic so we don't have to mask base::double()
  if (identical(type, double())) {
    type <- float64()
  }
  if (!inherits(type, "DataType")) {
    stop(name, " must be a DataType, not ", class(type), call. = FALSE)
  }
  type
}

canonical_type_str <- function(type_str) {
  # canonicalizes data type strings, converting data type function names and
  # aliases to match the strings returned by DataType$ToString()
  assert_that(is.string(type_str))
  if (grepl("[([<]", type_str)) {
    stop("Cannot interpret string representations of data types that have parameters", call. = FALSE)
  }
  switch(type_str,
    int8 = "int8",
    int16 = "int16",
    int32 = "int32",
    int64 = "int64",
    uint8 = "uint8",
    uint16 = "uint16",
    uint32 = "uint32",
    uint64 = "uint64",
    float16 = "halffloat",
    halffloat = "halffloat",
    float32 = "float",
    float = "float",
    float64 = "double",
    double = "double",
    boolean = "bool",
    bool = "bool",
    utf8 = "string",
    large_utf8 = "large_string",
    large_string = "large_string",
    binary = "binary",
    large_binary = "large_binary",
    fixed_size_binary = "fixed_size_binary",
    string = "string",
    date32 = "date32",
    date64 = "date64",
    time32 = "time32",
    time64 = "time64",
    null = "null",
    timestamp = "timestamp",
    decimal128 = "decimal128",
    struct = "struct",
    list_of = "list",
    list = "list",
    large_list_of = "large_list",
    large_list = "large_list",
    fixed_size_list_of = "fixed_size_list",
    fixed_size_list = "fixed_size_list",
    duration = "duration",
    stop("Unrecognized string representation of data type", call. = FALSE)
  )
}

# vctrs support -----------------------------------------------------------
duplicate_string <- function(x, times) {
  paste0(rep(x, times = times), collapse = "")
}

indent <- function(x, n) {
  pad <- duplicate_string(" ", n)
  sapply(x, gsub, pattern = "(\n+)", replacement = paste0("\\1", pad))
}

#' @importFrom vctrs vec_ptype_full vec_ptype_abbr
#' @export
vec_ptype_full.arrow_fixed_size_binary <- function(x, ...) {
  paste0("fixed_size_binary<", attr(x, "byte_width"), ">")
}

#' @export
vec_ptype_full.arrow_list <- function(x, ...) {
  param <- vec_ptype_full(attr(x, "ptype"))
  if (grepl("\n", param)) {
    param <- paste0(indent(paste0("\n", param), 2), "\n")
  }
  paste0("list<", param, ">")
}

#' @export
vec_ptype_full.arrow_large_list <- function(x, ...) {
  param <- vec_ptype_full(attr(x, "ptype"))
  if (grepl("\n", param)) {
    param <- paste0(indent(paste0("\n", param), 2), "\n")
  }
  paste0("large_list<", param, ">")
}

#' @export
vec_ptype_full.arrow_fixed_size_list <- function(x, ...) {
  param <- vec_ptype_full(attr(x, "ptype"))
  if (grepl("\n", param)) {
    param <- paste0(indent(paste0("\n", param), 2), "\n")
  }
  paste0("fixed_size_list<", param, ", ", attr(x, "list_size"), ">")
}

#' @export
vec_ptype_abbr.arrow_fixed_size_binary <- function(x, ...) {
  vec_ptype_full(x, ...)
}
#' @export
vec_ptype_abbr.arrow_list <- function(x, ...) {
  vec_ptype_full(x, ...)
}
#' @export
vec_ptype_abbr.arrow_large_list <- function(x, ...) {
  vec_ptype_full(x, ...)
}
#' @export
vec_ptype_abbr.arrow_fixed_size_list <- function(x, ...) {
  vec_ptype_full(x, ...)
}
