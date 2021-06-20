# ``DeftLayout``

Map bit-level information packed in Swift Data bytes to properties of user-defined classes.


## Overview

DeftLayout is a framework for defining classes with properties that are not stored
directly, but instead are embedded in fragments of bytes in a Data array.
These compact encodings are commonly found in hardware and network protocols
where efficient representation is more important than the work required to prepare
and interpret the packed data.

Layouts are defined by subclassing one of the "Description" classes, which in
turn are subclasses of ``BitStorageCore``. Layouts declare computed properties
(via a provided property wrapper) that provide easier, idiomatic access to the
raw bits in the core.

## Defining a Layout

### Choose a base description

To define a layout, derive the custom layout from the description class that
best represents the packed encoding.

Each description class provides Position wrappers with initializer parameters
that should be natural for describing the positions of bits in the layout.

| Packed encoding | Position Wrapper |
| --- | --- |
| Single byte | ``ByteArrayDescription/Position`` |
| Big-endian word | ``WordDescription/Position`` |
| Multiple bytes | ``ByteArrayDescription/Position`` |

The description classes are derived from ``BitStorageCore``, which manages
access to the encoded storage.


### Define mapped properties

Each computed property is declared as a var, of a type that conforms
``BitEmbeddable``, and decorated with a @Position property wrapper from its
base class. The property wrapper generates the packing/unpacking code.
Packing works by using the ``BitEmbeddable`` conformance to obtain bits for a
RawValue representation of the type, then placing those bits into the range
of the storage bytes that are allocated to hold the property.

``BitEmbeddable`` includes extensions for most sized signed and unsigned
integer types, and for Bool (using the C convention of true = 1/false = 0).
For signed types, sign extension can be applied when expanding
storage bits into the raw type before conversion.
``BitEmbeddable`` may be satisfied by any type that is RawRepresentable,
which means enumerations can be mapped if the protocol is included in the
enum definition.

The '@Position' property wrappers identify a bit or range of bits, plus a
strategy for sign extension if needed. The ``ByteDescription/Position`` and
``WordDescription/Position`` intializers do not include a byte offset, but
offer positions for a single bit, or for the position of the largest and
smallest bit in a range. The ``ByteArrayDescription/Position`` has initializers
for positions within a byte or that span bytes.

Here is the layout of the (byte-based) command register for a temperature
probe, where the smallest four bits are used to identify a register to read or write:

    class MCP9808_PointerRegister: ByteDescription {
        enum RegisterPointer: UInt8, BitEmbeddable {
            /// Configuration register (CONFIG)
            case configuration = 0b0001
            //...
            /// Temperature register (TA)
            case temperature = 0b0101
        }
        @Position(msb: 3, lsb: 0)
        var command: RegisterPointer = .temperature
    }

Note how `RegisterPointer` conforms to ``BitEmbeddable`` in its definition, allowing
it to be decorated with @Position in the definition of the property named `command`.

Here is the layout of the (word-based) sensor registers returned by the probe:

    /// Current sensor readings: (temperature and alarm states). Read-only.
    ///
    /// [datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf) REGISTER 5-4
    class MCP9808_AmbientTemperatureRegister: WordDescription {
        // Datasheet p.24

        enum LimitFlag: UInt8, BitEmbeddable {
            case withinLimit = 0
            case outsideLimit = 1
        }

        @Position(bit: 15)
        var AmbientVsCritical: LimitFlag = .withinLimit

        @Position(bit: 14)
        var AmbientVsUpper: LimitFlag = .withinLimit

        @Position(bit: 13)
        var AmbientVsLower: LimitFlag = .withinLimit


        @Position(msb: 12, lsb: 0, extendNegativeBit: true)
        var temperatureSixteenthCelsius: Int = 0
    }


## Encoded Access

The base ``BitStorageCore`` class provides access to encoded data via its
``BitStorageCore/storage`` property. Data can be both read and written in
its encoded form.


Using the temperature probe example above, this code sets up a command and
and readies a response to be interpreted, uses another library to send the
command and read the reply into the result layout, and finally interprets the
result according to the layout:

    let command = MCP9808_PointerRegister()
    command.command = .temperature

    let result = MCP9808_AmbientTemperatureRegister()

    try! link.writeAndRead(sendFrom: command.storage.bytes, receiveInto: &result.storage.bytes)
    
    let temperature = Double(result.temperatureSixteenthCelsius) / 16.0

In both the send and the receive, the Data exchanged uses 
``BitStorageCore/storage``.``AssembledMessage/bytes``.
(Note how the encoded temperatureSixteenthCelsius Int is divided by 2^4
to reflect the 4 fixed fractional binary bits.)


## Failures

Setting a property where its RawValue overflows the bits available for packed storage
is a runtime abort.

Getting an enum from garbled backing storage results in a runtime abort.

Bit positions in @Position wrappers are not checked until runtime, and nonsensical
values cause an abort.


## Topics

### Accessing Packed Data

- ``BitStorageCore``
- ``AssembledMessage``

### Packed Representations

Derive new classes from these bases, adding ``BitEmbeddable`` properties and
defining their storage using Position wrappers.

- ``ByteDescription``
- ``WordDescription``
- ``ByteArrayDescription``

