<%
import re
from datetime import datetime
from pyldfparser.model import LogicalEncoding, PhysicalEncoding

def get_all_logic_encodings(encodings):
    return [encoding for encoding in encodings if isinstance(encoding, LogicalEncoding)]

def get_all_physical_encodings(encodings):
    return [encoding for encoding in encodings if isinstance(encoding, PhysicalEncoding)]

def encoding_text_to_enum_name(enc_name):
    return re.sub(r"[^0-9a-zA-Z]+", "", enc_name).upper()

def get_encoding_units(encoding):
    retval = "["
    if encoding.scale != 1:
        retval += f"{encoding.scale}"
    if encoding.text != "":
        retval += encoding.text
    retval += "] "
    return retval if retval != "[] " else ""
%>\
/**
 * @file
 * @brief LDF dependent LIN signal encodings
 * @internal
 *
 * @copyright (C) ${datetime.now().year} Melexis N.V.
 *
 * Melexis N.V. is supplying this code for use with Melexis N.V. processor based microcontrollers only.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.  MELEXIS N.V. SHALL NOT IN ANY CIRCUMSTANCES,
 * BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 *
 * @endinternal
 *
 * @ingroup application
 *
 * @details This file provides the LDF dependent LIN signal encodings and is auto generated based
 * upon ${args.ldf}.
 */

#ifndef LIN_SIGNALS_ENCODING_H_
    #define LIN_SIGNALS_ENCODING_H_
% for representation in parser.model.signal_representations:
<% logic_encodings = get_all_logic_encodings(representation.encoding_type.encodings) %>\
%     if len(logic_encodings) > 0:

/** Signal encoding '${representation.encoding_type.name}' enumeration values */
typedef enum ${representation.encoding_type.name}_e
{
%         for encoding in logic_encodings:
    E_${representation.encoding_type.name.upper()}_${encoding_text_to_enum_name(encoding.text)} = ${encoding.value},  /**< ${encoding.text} */
%         endfor
} ${representation.encoding_type.name}_t;
%     endif
\
<% physical_encodings = get_all_physical_encodings(representation.encoding_type.encodings) %>\
%     if len(physical_encodings) > 0:
%         for encoding in physical_encodings:
%             if encoding.max_value == 255:

/** Signal encoding '${representation.encoding_type.name}' type ${get_encoding_units(encoding)}*/
typedef uint8_t ${representation.encoding_type.name}_t;
%             elif encoding.max_value == 65535:

/** Signal encoding '${representation.encoding_type.name}' type ${get_encoding_units(encoding)}*/
typedef uint16_t ${representation.encoding_type.name}_t;
%             endif
\
%             if encoding.offset != 0:

/** Signal encoding '${representation.encoding_type.name}' offset ${get_encoding_units(encoding)}*/
#define C_${representation.encoding_type.name.upper()}_OFFSET ${str(encoding.offset).replace("-", "")}
%             endif
%         endfor
%     endif
% endfor

#endif  /* LIN_SIGNALS_ENCODING_H */
