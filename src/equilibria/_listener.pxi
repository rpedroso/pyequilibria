cdef extern from * namespace "Monero":
    '''
static void from_cpp_money_spent(void *listener, const std::string txId, uint64_t amount);
static void from_cpp_money_received(void *listener, const std::string txId, uint64_t amount);
static void from_cpp_unconfirmed_money_received(void *listener, const std::string txId, uint64_t amount);
static void from_cpp_new_block(void *listener, uint64_t height);
static void from_cpp_updated(void *listener);
static void from_cpp_refreshed(void *listener);

namespace Monero {

class Listener : public WalletListener
{
void *m_py_listener;
public:
    Listener() {};
    ~Listener() {};
    void moneySpent(const std::string& txid, uint64_t amount) {
        //std::cout << "c++ MoneySpent\\n";
        from_cpp_money_spent(m_py_listener, txid, amount);
    };
    void moneyReceived(const std::string& txid, uint64_t amount) {
        //std::cout << "c++ MoneyReceived\\n";
        from_cpp_money_received(m_py_listener, txid, amount);
    };
    void unconfirmedMoneyReceived(const std::string& txid, uint64_t amount) {
        //std::cout << "c++ unconfirmedMoneyReceived\\n";
        from_cpp_unconfirmed_money_received(m_py_listener, txid, amount);
    };
    void newBlock(uint64_t height) {
        //std::cout << "c++ newBlock\\n";
        from_cpp_new_block(m_py_listener, height);
    };
    void updated() {
        //std::cout << "c++ updated\\n";
        from_cpp_updated(m_py_listener);
    };
    void refreshed() {
        //std::cout << "c++ refreshed\\n";
        from_cpp_refreshed(m_py_listener);
    };
    void set_py_listener(void *listener) {
        m_py_listener = listener;
    };
};


void _set_listener(Wallet *w, void *listener) {
    Listener *l = new Listener;
    l->set_py_listener(listener);
    w->setListener(l);
}

}
    '''
    cdef cppclass _Listener(c_WalletListener):
        pass

    void _set_listener(c_Wallet *w, void *listener)


from traceback import print_exc

cdef void from_cpp_money_spent "from_cpp_money_spent" (void *listener, string txId, uint64_t amount) noexcept nogil:
    with gil:
        try:
            (<object>listener).money_spent(txId, amount)
        except:
            print_exc()

cdef void from_cpp_money_received "from_cpp_money_received" (void *listener, string txId, uint64_t amount) noexcept nogil:
    with gil:
        try:
            (<object>listener).money_received(txId, amount)
        except:
            print_exc()

cdef void from_cpp_unconfirmed_money_received "from_cpp_unconfirmed_money_received" (void *listener, string txId, uint64_t amount) noexcept nogil:
    with gil:
        try:
            (<object>listener).unconfirmed_money_received(txId, amount)
        except:
            print_exc()

cdef void from_cpp_new_block "from_cpp_new_block" (void *listener, uint64_t height) noexcept nogil:
    with gil:
        try:
            (<object>listener).new_block(height)
        except:
            print_exc()

cdef void from_cpp_updated "from_cpp_updated" (void *listener) noexcept nogil:
    with gil:
        try:
            (<object>listener).updated()
        except:
            print_exc()

cdef void from_cpp_refreshed "from_cpp_refreshed" (void *listener) noexcept nogil:
    with gil:
        try:
            (<object>listener).refreshed()
        except:
            print_exc()


cdef void cy_set_listener(c_Wallet *w, listener):
    # Py_INCREF(listener)
    _set_listener(w, <void*>listener)

