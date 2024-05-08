# # distutils: language = c++
# # cython: c_string_type=unicode, c_string_encoding=utf8
# from libcpp.string cimport string
# 
# from .wallet_api cimport c_Status, c_Priority


cpdef enum class _Priority:
    Default = c_Priority.Priority_Default
    Low     = c_Priority.Priority_Low
    Medium  = c_Priority.Priority_Medium
    High    = c_Priority.Priority_High
    Last    = c_Priority.Priority_Last


cdef class PendingTransaction:
    Priority = _Priority
    cdef c_PendingTransaction *o

    #def __cinit__(self):
    #    self.o = new PendingTransactionImpl()

    #def __cinit__(self):
    #    self.ptr_owner = False

    #def __dealloc__(self):
    #    # De-allocate if not null and flag is set
    #    if self.o is not NULL and self.ptr_owner is True:
    #        free(self.o)
    #        self.o = NULL

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    def status(self):
        # return <c_Status>self.o.status()
        return self.o.status()

    def error_string(self):
        return self.o.errorString()

    def commit(self, string filename=b'', bint overwrite=False):
    # def commit(self, filename=b'', bint overwrite=False):
        return self.o.commit(filename, overwrite)

    def amount(self):
        return self.o.amount()

    def dust(self):
        return self.o.dust()

    def fee(self):
        return self.o.fee()

    def tx_id(self):
        return self.o.txid()

    def tx_count(self):
        return self.o.txCount()

    def subaddr_account(self):
        return self.o.subaddrAccount()

    def subaddr_indices(self):
        return self.o.subaddrIndices()

    def multisig_sign_data(self):
        return self.o.multisigSignData()

    def sign_multisig_tx(self):
        self.o.signMultisigTx()

    def signersKeys(self):
        return self.signersKeys()

    @staticmethod
    cdef PendingTransaction from_ptr(void *o):
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef PendingTransaction wrapper = PendingTransaction.__new__(PendingTransaction)
        wrapper.o = <c_PendingTransaction*>o
        #wrapper.ptr_owner = owner
        return wrapper
