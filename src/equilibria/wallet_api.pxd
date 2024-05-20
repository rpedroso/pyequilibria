from libc.stdint cimport uint64_t, uint32_t, uint8_t, int64_t
from libc.stddef cimport size_t
from libc.time cimport time_t
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.set cimport set
from libcpp.unordered_set cimport unordered_set


cdef extern from "wallet2_api.h" namespace "Monero::Utils":
    bint isAddressLocal(string &hostaddr)
    void onStartup()


cdef extern from "wallet2_api.h" namespace "Monero::Wallet":
    cdef cppclass optional[T]:
        pass

    cdef enum c_ConnectionStatus "Monero::Wallet::ConnectionStatus":
        ConnectionStatus_Disconnected
        ConnectionStatus_Connected
        ConnectionStatus_WrongVersion

    cdef enum c_Status "Monero::Wallet::Status":
        Status_Ok
        Status_Error
        Status_Critical

#cdef extern from "wallet/api/wallet2_api.h" namespace "Monero":
#    cdef cppclass c_PendingTransaction "Monero::PendingTransaction":
#        pass
cdef extern from "wallet2_api.h" namespace "Monero::WalletManagerFactory":
    cdef enum c_LogLevel "Monero::WalletManagerFactory::LogLevel":
        LogLevel_Silent
        LogLevel_0
        LogLevel_1
        LogLevel_2
        LogLevel_3
        LogLevel_4
        LogLevel_Min
        LogLevel_Max


cdef extern from "wallet2_api.h" namespace "Monero::PendingTransaction":
    #cdef enum Status:
    #    Status_Ok
    #    Status_Error
    #    Status_Critical

    cdef enum c_Priority "Monero::PendingTransaction::Priority":
        Priority_Default
        Priority_Low
        Priority_Medium
        Priority_High
        Priority_Last

    cdef cppclass c_PendingTransaction "Monero::PendingTransaction":
        int status() except +
        string errorString() except +
        bint commit(const string &filename, bint overwrite) except +
        uint64_t amount() except +
        uint64_t dust() except +
        uint64_t fee() except +
        vector[string] txid() except +
        uint64_t txCount() except +
        vector[uint32_t] subaddrAccount() except +
        vector[set[uint32_t]] subaddrIndices() except +

        string multisigSignData() except +
        void signMultisigTx() except +
        vector[string] signersKeys() except +


#    cpdef enum class PendingTransaction_Priority "Monero::PendingTransaction::Priority":
#        Priority_Default = 0
#        Priority_Low = 1
#        Priority_Medium = 2
#        Priority_High = 3
#        Priority_Last

#cdef extern from "wallet/api/pending_transaction.h" namespace "Monero":
#    cdef cppclass PendingTransactionImpl(c_PendingTransaction):
#        int status() const

cdef extern from "wallet2_api.h" namespace "Monero":
    cdef cppclass c_TransactionInfo "Monero::TransactionInfo":
        int direction() except + nogil
        # true if hold
        bint isPending() except + nogil
        bint isFailed() except + nogil
        uint64_t amount() except + nogil
        # always 0 for incoming txes
        uint64_t fee() except + nogil
        uint64_t blockHeight() except + nogil
        set[uint32_t] subaddrIndex() except + nogil
        uint32_t subaddrAccount() except + nogil
        string label() except + nogil

        string hash() except + nogil
        time_t timestamp() except + nogil
        string paymentId() except + nogil
        #const vector[Transfer] &transfers() except + nogil
        uint64_t confirmations() except + nogil
        uint64_t unlockTime() except + nogil
        bint isServiceNodeReward() except + nogil
        bint isMinerReward() except + nogil


cdef extern from "wallet2_api.h" namespace "Monero::TransactionHistory":
    cdef cppclass c_TransactionHistory "Monero::TransactionHistory":
        int count() except + nogil
        c_TransactionInfo * transaction(int index) except + nogil
        c_TransactionInfo * transaction_str "transaction" (const string &id) except + nogil
        vector[c_TransactionInfo*] getAll() except + nogil
        void refresh() except + nogil


cdef extern from "wallet2_api.h" namespace "Monero":
    cdef enum c_NetworkType "Monero::NetworkType": #uint8_t {
         MAINNET = 0
         TESTNET
         STAGENET

    #cdef cppclass _PendingTransaction "Monero::PendingTransaction":
    #    pass

    cdef cppclass c_WalletListener "Monero::WalletListener" nogil

    cdef cppclass c_Wallet "Monero::Wallet" nogil:
        bint open(const string &path, const string &password) except + nogil
        bint close(bint store)

        string seed() except +
        string getSeedLanguage() except +

        # deprecated: use safe alternative statusWithErrorString
        int status() except +
        # deprecated: use safe alternative statusWithErrorString
        string errorString() except +

        # returns both error and error string atomically. suggested to use in instead of status() and errorString()
        void statusWithErrorString(int& status, string& errorString) except +
        void setRefreshFromBlockHeight(uint64_t refresh_from_block_height) except + nogil
        uint64_t getRefreshFromBlockHeight() except + nogil
        bint setPassword(const string &password)  except +
        bint setDevicePin(const string &pin) except +
        bint setDevicePassphrase(const string &passphrase) except +
        string address(uint32_t accountIndex, uint32_t addressIndex) except +
        string mainAddress() except +
        string path() except +
        c_NetworkType nettype() except +
        bint mainnet() except +
        bint testnet() except +
        bint stagenet() except +
        # returns current hard fork info
        void hardForkInfo(uint8_t &version, uint64_t &earliest_height) except +
        # check if hard fork rules should be used
        bint useForkRules(uint8_t version, int64_t early_blocks) except +

        string integratedAddress(const string &payment_id) except +

        string secretViewKey() except +
        string publicViewKey() except +
        string secretSpendKey() except +
        string publicSpendKey() except +
        string publicMultisigSignerKey() except +

        bint store(const string &path) except + nogil
        string filename() except +
        string keysFilename() except +

        bint connectToDaemon() except +
        c_ConnectionStatus connected() except +
        void setTrustedDaemon(bint arg) except +
        bint trustedDaemon() except +
        uint64_t balance(uint32_t accountIndex) except +
        uint64_t balanceAll() except +
        uint64_t unlockedBalance(uint32_t accountIndex) except +
        uint64_t unlockedBalanceAll() except +

        uint64_t blockChainHeight() except + nogil

        bint init(const string &daemon_address,
                    uint64_t upper_transaction_size_limit,
                    const string &daemon_username,
                    const string &daemon_password,
                    bint use_ssl, bint lightWallet) except + nogil

        c_PendingTransaction * createTransaction(const string &dst_addr, const string &payment_id,
                                                   uint64_t amount, uint32_t mixin_count,
                                                   c_Priority,
                                                   uint32_t subaddr_account,
                                                   set[uint32_t] subaddr_indices) except +

        c_PendingTransaction * createSweepUnmixableTransaction() except +

        c_PendingTransaction*  restoreMultisigTransaction(const string& signData) except +

        bint importKeyImages(const string &filename) except +

        # Logger
        @staticmethod
        void log_init "init" (const char *argv0,
                    const char *default_log_base_name,
                    const string &log_path, bint console) except +

        bint createWatchOnly(const string &path, const string &password, const string &language) except +
        uint64_t daemonBlockChainHeight() except +
        uint64_t daemonBlockChainTargetHeight() except +

        bint synchronized() except +

        @staticmethod
        string displayAmount(uint64_t amount) except +
        @staticmethod
        uint64_t amountFromString(const string &amount) except +
        @staticmethod
        uint64_t amountFromDouble(double amount) except +
        @staticmethod
        string genPaymentId() except +
        @staticmethod
        bint paymentIdValid(string &paiment_id) except +
        # Check if the string represents a valid public key (regardless of whether the service node actually exists or not)
        @staticmethod
        bint serviceNodePubkeyValid(string &str) except +
        @staticmethod
        bint addressValid(string &str, c_NetworkType nettype) except +
        @staticmethod
        bint keyValid(const string &secret_key_string, const string &address_string, bint isViewKey, c_NetworkType nettype, string &error) except +
        @staticmethod
        string paymentIdFromAddress(const string &str, c_NetworkType nettype) except +
        @staticmethod
        uint64_t maximumAllowedAmount() except +

        void startRefresh() except + nogil
        void pauseRefresh() except + nogil
        bint refresh() except + nogil
        void refreshAsync() except + nogil

        bint rescanBlockchain() except + nogil
        void rescanBlockchainAsync() except + nogil
        void setAutoRefreshInterval(int millis) except + nogil
        int autoRefreshInterval() except + nogil

        uint32_t defaultMixin() except +
        void setDefaultMixin(uint32_t arg) except +

        bint setUserNote(const string &txid, const string &note) except +
        string getUserNote(const string &txid) except +

        string getDefaultDataDir() except +

        c_TransactionHistory * history() except + nogil

        void setListener(c_WalletListener *l)

        void addSubaddressAccount(const string& label)
        size_t numSubaddressAccounts() except + nogil
        size_t numSubaddresses(uint32_t accountIndex) except + nogil
        void addSubaddress(uint32_t accountIndex, const string& label)
        string getSubaddressLabel(uint32_t accountIndex,
                                  uint32_t addressIndex) except + nogil
        void setSubaddressLabel(uint32_t accountIndex,
                                uint32_t addressIndex,
                                const string &label)

        uint64_t getBytesReceived()
        uint64_t getBytesSent()


cdef extern from "wallet2_api.h" namespace "Monero":

    cdef cppclass c_WalletListener "Monero::WalletListener" nogil:

        #"""
        #@brief moneySpent - called when money spent
        #@param txId       - transaction id
        #@param amount     - amount
        #"""
        void moneySpent(const string &txId, uint64_t amount)

        #/**
        # * @brief moneyReceived - called when money received
        # * @param txId          - transaction id
        # * @param amount        - amount
        # */
        #virtual void moneyReceived(const std::string &txId, uint64_t amount) = 0;
        #
        #**
        #* @brief unconfirmedMoneyReceived - called when payment arrived in tx pool
        #* @param txId          - transaction id
        #* @param amount        - amount
        #*/
        #virtual void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount) = 0;
        #
        #/**
        # * @brief newBlock      - called when new block received
        # * @param height        - block height
        # */
        #virtual void newBlock(uint64_t height) = 0;
        #
        #/**
        # * @brief updated  - generic callback, called when any event (sent/received/block reveived/etc) happened with the wallet;
        # */
        #virtual void updated() = 0;


        #"""
        #@brief refreshed - called when wallet refreshed by background thread
        #                   or explicitly refreshed by calling "refresh"
        #                   synchronously
        #"""
        void refreshed()
    #
    #    /**
    #     * @brief called by device if the action is required
    #     */
    #    virtual void onDeviceButtonRequest(uint64_t code) { (void)code; }
    #
    #    /**
    #     * @brief called by device if the button was pressed
    #     */
    #    virtual void onDeviceButtonPressed() { }
    #
    #    /**
    #     * @brief called by device when PIN is needed
    #     */
    #    virtual optional<std::string> onDevicePinRequest() {
    #        throw std::runtime_error("Not supported");
    #    }
    #
    #    /**
    #     * @brief called by device when passphrase entry is needed
    #     */
    #    virtual optional<std::string> onDevicePassphraseRequest(bool & on_device) {
    #        on_device = true;
    #        return optional<std::string>();
    #    }
    #
    #    /**
    #     * @brief Signalizes device operation progress
    #     */
    #    virtual void onDeviceProgress(const DeviceProgress & event) { (void)event; };
    #
    #    /**
    #     * @brief If the listener is created before the wallet this enables to set created wallet object
    #     */
    #    virtual void onSetWallet(Wallet * wallet) { (void)wallet; };
    #};


    cdef cppclass c_WalletManager "Monero::WalletManager":
        #bint create(const string &path, const string &password, const string &language)
        c_Wallet *createWallet(const string &path, const string &password,
                        const string &language, c_NetworkType nettype,
                        uint64_t kdf_rounds) except + nogil
    
        c_Wallet *openWallet(const string &path, const string &password,
                            c_NetworkType nettype, uint64_t kdf_rounds,
                            c_WalletListener *listener) except + nogil
    
        bint closeWallet(c_Wallet *wallet, bint store) except + nogil

        # \brief  recovers existing wallet using mnemonic (electrum seed)
        # \param  path           Name of wallet file to be created
        # \param  password       Password of wallet file
        # \param  mnemonic       mnemonic (25 words electrum seed)
        # \param  nettype        Network type
        # \param  restoreHeight  restore from start height
        # \param  kdf_rounds     Number of rounds for key derivation function
        # \param  seed_offset    Seed offset passphrase (optional)
        # \return                Wallet instance (Wallet::status() needs to be
        #                        called to check if recovered successfully)
        c_Wallet * recoveryWallet(const string &path, const string &password,
                                    const string &mnemonic,
                                    c_NetworkType nettype,
                                    uint64_t restoreHeight,
                                    uint64_t kdf_rounds,
                                    const string &seed_offset) except + nogil

        c_Wallet * createWalletFromKeys(const string &path,
                                    const string &password,
                                    const string &language,
                                    c_NetworkType nettype,
                                    uint64_t restoreHeight,
                                    const string &addressString,
                                    const string &viewKeyString,
                                    const string &spendKeyString,
                                    uint64_t kdf_rounds) except + nogil

        bint walletExists(const string &path) except + nogil
    
        bint verifyWalletPassword(const string &keys_file_name,
                const string &password, bint no_spend_key,
                uint64_t kdf_rounds) except + nogil
    
        # 
        # \brief findWallets - searches for the wallet files by given path name recursively
        # \param path - starting point to search
        # \return - list of strings with found wallets (absolute paths);
        # 
        vector[string] findWallets(const string &path) except + nogil
    
        # returns verbose error string regarding last error
        string errorString() except + nogil
    
        # set the daemon address (hostname and port)
        void setDaemonAddress(const string &address) except + nogil
    
        # returns whether the daemon can be reached, and its version number
        bint connected(uint32_t *version) except + nogil
    
        # returns current blockchain height
        uint64_t blockchainHeight() except + nogil
    
        # returns current blockchain target height
        uint64_t blockchainTargetHeight() except + nogil
    
        # returns current network difficulty
        uint64_t networkDifficulty() except + nogil
    
        # returns current mining hash rate (0 if not mining)
        double miningHashRate() except + nogil
    
        # returns current block target
        uint64_t blockTarget() except + nogil

        # returns true if mining
        bint isMining() except + nogil


    #cdef enum LogLevel:
    #    LogLevel_Silent
    #    LogLevel_0
    #    LogLevel_1
    #    LogLevel_2
    #    LogLevel_3
    #    LogLevel_4
    #    LogLevel_Min
    #    LogLevel_Max


    cdef cppclass c_WalletManagerFactory "Monero::WalletManagerFactory":
        @staticmethod
        c_WalletManager * getWalletManager() except + nogil
        @staticmethod
        void setLogLevel(int level) except + nogil
        @staticmethod
        void setLogCategories(const string &categories) except + nogil

