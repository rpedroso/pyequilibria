# distutils: language = c++
# cython: c_string_type=unicode, c_string_encoding=utf8

#from libc.stdint cimport uint64_t, uint32_t, uint8_t, int64_t
#from libc.stddef cimport size_t
#from libcpp.string cimport string
#from libcpp.vector cimport vector
#from libcpp.set cimport set
#from libcpp.unordered_set cimport unordered_set
from libc.time cimport time_t

#cdef extern from "../../equilibria/src/wallet/api/utils.cpp" namespace "Monero::Utils":
#    pass
#

cdef class TransactionInfo:
    cdef c_TransactionInfo *o
    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    def direction(self):
        cdef int r
        with nogil:
            r = self.o.direction()
        return r

    # true if hold
    def is_pending(self):
        cdef bint r
        with nogil:
            r = self.o.isPending()
        return r

    def is_failed(self):
        cdef bint r
        with nogil:
            r = self.o.isFailed()
        return r

    def amount(self):
        cdef uint64_t r
        with nogil:
            r = self.o.amount()
        return r

    # always 0 for incoming txes
    def fee(self):
        cdef uint64_t r
        with nogil:
            r = self.o.fee()
        return r

    def block_height(self):
        cdef uint64_t r
        with nogil:
            r = self.o.blockHeight()
        return r

    def subaddr_index(self):
        cdef set[uint32_t] r
        with nogil:
            r = self.o.subaddrIndex()
        return r

    def subaddr_account(self):
        cdef uint32_t r
        with nogil:
            r = self.o.subaddrAccount()
        return r

    def label(self):
        cdef string r
        with nogil:
            r = self.o.label()
        return r

    def hash(self):
        cdef string r
        with nogil:
            r = self.o.hash()
        return r

    def timestamp(self):
        cdef time_t r
        with nogil:
            r = self.o.timestamp()
        return r

    def payment_id(self):
        return self.o.paymentId()

    #const vector[Transfer] &transfers() except + nogil

    def confirmations(self):
        cdef uint64_t r
        with nogil:
            r = self.o.confirmations()
        return r

    def unlock_time(self):
        cdef uint64_t r
        with nogil:
            r = self.o.unlockTime()
        return r

    def is_service_node_reward(self):
        cdef bint r
        with nogil:
            r = self.o.isServiceNodeReward()
        return r

    def is_miner_reward(self):
        cdef bint r
        with nogil:
            r = self.o.isMinerReward()
        return r


    @staticmethod
    cdef TransactionInfo from_ptr(void *o):
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef TransactionInfo wrapper = TransactionInfo.__new__(TransactionInfo)
        wrapper.o = <c_TransactionInfo*>o
        #wrapper.ptr_owner = owner
        return wrapper


