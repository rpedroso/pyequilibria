# distutils: language = c++
# cython: c_string_type=unicode, c_string_encoding=utf8

#from libc.stdint cimport uint64_t, uint32_t, uint8_t, int64_t
#from libc.stddef cimport size_t
#from libcpp.string cimport string
#from libcpp.vector cimport vector
#from libcpp.set cimport set
#from libcpp.unordered_set cimport unordered_set

#cdef extern from "../../equilibria/src/wallet/api/utils.cpp" namespace "Monero::Utils":
#    pass
#

# from . cimport transaction_info
# from .transaction_info cimport c_TransactionInfo


cdef class TransactionHistory:
    cdef c_TransactionHistory *o
    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")


    def count(self):
        cdef int r
        with nogil:
            r = self.o.count()
        return r

    def transaction(self, int index):
        cdef c_TransactionInfo *h
        with nogil:
            h = self.o.transaction(index)
        if h is NULL:
            return None
        return TransactionInfo.from_ptr(h)

    def transaction_from_str(self, string index):
        cdef c_TransactionInfo *h
        with nogil:
            h = self.o.transaction_str(index)
        if h is NULL:
            return None
        return TransactionInfo.from_ptr(h)

    def account_transaction_from_str(self, uint32_t subaddr_account, string txid):
        # boost::shared_lock<boost::shared_mutex> lock(m_historyMutex);
        # auto itr = std::find_if(m_history.begin(), m_history.end(),
        #                         [&](const TransactionInfo * ti) {
        #     return ti->hash() == id;
        # });
        # return itr != m_history.end() ? *itr : nullptr;
        cdef vector[c_TransactionInfo *] h_list
        h_list = self.o.getAll()
        for tx in h_list:
            if tx.hash() == txid and subaddr_account == tx.subaddrAccount():
                return TransactionInfo.from_ptr(tx)
        return None

    def get_all(self):
        cdef vector[c_TransactionInfo *] h_list
        cdef c_TransactionInfo *h
        with nogil:
            h_list = self.o.getAll()
        for h in h_list:
            yield(TransactionInfo.from_ptr(h))

        #return TransactionInfo.from_ptr(h)
    def refresh(self):
        with nogil:
            self.o.refresh()

    @staticmethod
    cdef TransactionHistory from_ptr(void *o):
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef TransactionHistory wrapper = TransactionHistory.__new__(TransactionHistory)
        wrapper.o = <c_TransactionHistory*>o
        #wrapper.ptr_owner = owner
        return wrapper


