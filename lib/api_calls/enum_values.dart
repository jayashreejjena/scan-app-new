/// A set of enums use all over the
library;

// ignore_for_file: constant_identifier_names

/// RequestType
enum Request {
  get,
  post,
  put,
  patch,
  delete,
  exotelCall,
  multipart
}

/// Type of the Message
enum TypeOfMessageMessage {
  error,
  information,
  success,
}
