// Copyright 2018 ProximaX Limited. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

#ifndef message_encryption_h
#define message_encryption_h

int create_random_bytes(unsigned char* buff, size_t size);
void create_shared_key(unsigned char* shared_key, const unsigned char* public_key, const unsigned char* private_key, const unsigned char* salt);

#endif /* message_encryption_h */