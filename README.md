# Deft Layout

DEvices from swiFT


A library providing typed access to bit-level information packed into Swift Data bytes.


Goals:
- maximize use and call-site readability
- encourage discovery
  - minimize use of external libraries
- exemplify unit-testable design


Features:

Property wrappers and a bit-level insertion/extraction helper provide bit descriptions that are very close device datasheets when declared,
and then allow idiomatic Swift type useage when used. This mapping insulates the library user from raw bit operations, hardcoded masks, and other "magic" constants.


## Installation

Swift Package Manager


## Usage

### Describe messages

The underlying encoded bytes of the message are represented by an AssembledMessage.

The DeftLayout module provides support for mapping particular bits in AssembledMessage Data to properties in a message object.


Typical hierarchy for a mapping class:

BitStorageCore  // manages the AssembledMessage
[ByteArray]Description // provides @Position wrappers that "make sense" for the representation
[UserClass]Layout // uses @Position wrappers to add properties of the message


#### Example: a packed, 5-byte message

The TEA5767 radio tuner has only one command, consisting of a write of 5 bytes. Its datasheet describes the bytes by byte index and bits within the 8-bit byte. The ByteArrayDescription best supports this longer  array with byte-oriented descriptions.

    class TEA5767_WriteLayout: ByteArrayDescription {
        enum SearchStopLevel: UInt8, BitEmbeddable {
            case low = 0b01
            case medium = 0b10
            case high = 0b11
        }
        @Position(ofByte: 3, msb: 6, lsb: 5)
        var searchStopLevel: SearchStopLevel = .high
        // ...
    }

#### Example: a 2-byte message as a big-endian word

The MCP9808 defines a number of different 1- or 2-byte messages. The 2-byte messages are documented in the datasheet as big-endian words. The WordDescription @Position wrappers idiomatically handle positioning bits between 0 and 15 and encode them to bytes with the expected endian-ness:

    class MCP9808_AmbientTemperatureRegister: WordDescription {
        enum LimitFlag: UInt8, BitEmbeddable {
            case withinLimit = 0
            case outsideLimit = 1
        }
        //...
        @Position(bit: 13)
        var AmbientVsLower: LimitFlag = .withinLimit
    
        @Position(msb: 12, lsb: 0, .extendNegativeBit)
        var temperatureSixteenthCelsius: Int = 0
    }

Because WordDescription describes precisely two bytes (or one word), its @Position structs do not offer byte or word index/offset.

### Using Message Layouts

Obtain the assembled bytes via the `storage` property via the base class.

To decode data, populate the underlying AssembledMessage `storage` with bytes, then read the properties via the layout class.


## Implementation

@Position wrappers adopt the CoderAdapter protocol, which requires they provide and set up a ByteCoder that it wires to the AssembledMessage storage.


## Issues

The Swift 5.1 compiler will crash if more than one property wrapper structure is defined in the application
with the same name, even when those structures are defined within the scope of different classes.

This appears fixed in 5.2, but Swift binaries are not yet available for the RPi.
