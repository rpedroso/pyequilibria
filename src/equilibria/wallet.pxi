# distutils: language = c++
# cython: c_string_type=unicode, c_string_encoding=utf8

from .wallet_api cimport c_NetworkType, c_Status, c_ConnectionStatus
# from . cimport transaction_history
# from . cimport pending_transaction
# from .pending_transaction cimport PendingTransaction


cpdef enum class _ConnectionStatus:
    Disconnected = c_ConnectionStatus.ConnectionStatus_Disconnected
    Connected    = c_ConnectionStatus.ConnectionStatus_Connected
    WrongVersion = c_ConnectionStatus.ConnectionStatus_WrongVersion


cpdef enum class _Status:
    Ok       = c_Status.Status_Ok
    Error    = c_Status.Status_Error
    Critical = c_Status.Status_Critical


cdef class Wallet:
    cdef c_Wallet *o
    ConnectionStatus = _ConnectionStatus
    Status = _Status

    # def __cinit__(self, nettype=c_NetworkType.MAINNET, kdf_rounds=1):
    #     self.o = new WalletImpl(nettype, kdf_rounds)
    #     if self.o is NULL:
    #         raise MemoryError

    def __dealloc__(self):
        if self.o is not NULL:
            del self.o
            self.o = NULL

    # def create(self, string path, string password, string language):
    #     cdef bint r
    #     with nogil:
    #         r = self.o.create(path, password, language)
    #     __status_with_error_string(self.o)
    #     return r

    # def open(self, string path, string password):
    #     cdef:
    #         bint r
    #     with nogil:
    #         r = self.o.open(path, password)
    #     return r

    # def close(self, bint store=True):
    #     with nogil:
    #         r = self.o.close(store)
    #     return r

    def seed(self):
      return self.o.seed()

    def get_seed_language(self):
        return self.o.getSeedLanguage()

    def status(self):
        return self.o.status()

    def error_string(self):
        return self.o.errorString()

    def status_with_error_string(self):
        cdef:
            int status = 0
            string err_str

        self.o.statusWithErrorString(status, err_str)
        return status, err_str

    def set_refresh_from_block_height(self, uint64_t refresh_from_block_height):
        cdef uint64_t c_refresh_from_block_height
        c_refresh_from_block_height = refresh_from_block_height
        with nogil:
            self.o.setRefreshFromBlockHeight(c_refresh_from_block_height)

    def get_refresh_from_block_height(self):
        cdef uint64_t r
        with nogil:
            r = self.o.getRefreshFromBlockHeight()
        return r

    def address(self, accountIndex=0, addressIndex=0):
        return self.o.address(accountIndex, addressIndex)

    def main_address(self): 
        return self.o.mainAddress()

    def path(self): 
        return self.o.path()

    def nettype(self): 
        return self.o.nettype()

    def mainnet(self): 
        return self.o.mainnet()

    def testnet(self): 
        return self.o.testnet()

    def stagenet(self): 
        return self.o.stagenet()

    def hard_fork_info(self, uint8_t version):
        cdef:
            uint64_t earliest_height = 0

        self.o.hardForkInfo(version, earliest_height)
        return earliest_height

    def use_fork_rules(self, version, early_blocks):
        return self.o.useForkRules(version, early_blocks)

    def integrated_address(self, payment_id):
        return self.o.integratedAddress(payment_id)

    def secret_view_key(self):
        """
        Returns:
            secret view key
        """
        return self.o.secretViewKey()

    def public_view_key(self):
        """
        Returns:
            public view key
        """
        return self.o.publicViewKey()

    def secret_spent_key(self):
        """
        Returns:
            secret spend key
        """
        return self.o.secretSpendKey()

    def public_spent_key(self):
        """
        Returns:
            public spend key
        """
        return self.o.publicSpendKey()

    def public_multisig_signer_key(self):
        """
        Returns public signer key

        Returns:
            public multisignature signer key or empty string if wallet is not multisig

        """
        return self.o.publicMultisigSignerKey()

    def store(self, path=None):
        """
        Stores wallet to file.

        Args:
            path: main filename to store wallet to. additionally stores
                    address file and keys file.
                    To store to the same file, just pass empty string;
        Returns:
            True if successul
        """
        cdef int r
        cdef string c_path
        if path is None:
            c_path = b""
        with nogil:
            r = self.o.store(c_path)  
        return r

    def filename(self):
        """
        Returns wallet filename
        """
        return self.o.filename()

    def keys_filename(self):
        """
        Returns keys filename. Usually this formed as "wallet_filename".keys
        """
        return self.o.keysFilename()

    def connect_to_daemon(self):
        """
        Connects to the daemon. TODO: check if it can be removed
        """
        return self.o.connectToDaemon()

    def connected(self):
        """
        Checks if the wallet connected to the daemon

        Returns:
            Return ConnectionStatus

        """
        return Wallet.ConnectionStatus(self.o.connected())

    def set_trusted_daemon(self, arg):
        self.o.setTrustedDaemon(arg)

    def trusted_daemon(self):
        return self.o.trustedDaemon()

    def balance(self, index=0):
        return self.o.balance(index)

    def balance_all(self):
        return self.o.balanceAll()

    def unlocked_balance(self, index=0):
        return self.o.unlockedBalance(index)

    def unlocked_balance_all(self):
        return self.o.unlockedBalanceAll()

    def blockchain_height(self):
        """
        Get current blockchain height

        Returns:
            The current blockchain height

        """
        cdef uint64_t r
        with nogil:
            r = self.o.blockChainHeight()
        return r

    def init(self, string daemon_address,
                uint64_t upper_transaction_size_limit=0, 
                daemon_username="", daemon_password="", 
                bint use_ssl=False, bint lightWallet=False):
        """
        initializes wallet with daemon connection params.

        if daemon_address is local address, "trusted daemon" will be set to
        true forcibly start_refresh() should be called when wallet is
        initialized.

        Args:
            daemon_address (str) : daemon address in "hostname:port" format
            upper_transaction_size_limit (int):
            daemon_username (str) :
            daemon_password (str) :
            lightWallet (bool) : start wallet in light mode, connect to a
                                 openequilibria compatible server.

        Returns:
            True on success
        """
        cdef:
            bint r
            c_ConnectionStatus conn_status
            string c_daemon_username = daemon_username
            string c_daemon_password = daemon_password
        with nogil:
            r = self.o.init(daemon_address, upper_transaction_size_limit,
                    c_daemon_username, c_daemon_password, use_ssl, lightWallet)
            # It seems that init always return True, but there are cases, for
            # example when the hostname cannot be resolved. In this case,
            # init returns True but there is no connections to daemon.
            # There is an exception that is swallowed. So we check for
            # connections status
            conn_status = self.o.connected()
        return conn_status == c_ConnectionStatus.ConnectionStatus_Connected

    def create_watch_only(self, path, password, language):
        return self.o.createWatchOnly(path, password, language)

    def create_transaction(self, dst_addr, payment_id, amount, mixin_count,
                           priority=PendingTransaction.Priority.Low,
                           subaddr_account=0, subaddr_indices=()):
        pass
        """
        createTransaction creates transaction. if dst_addr is an integrated
        address, payment_id is ignored

        Args:
            dst_addr:        destination address as string
            payment_id:      optional payment_id, can be empty string
            amount:          amount
            mixin_count:     mixin count. if 0 passed, wallet will use default
                             value
            subaddr_account: subaddress account from which the input funds are
                             taken
            subaddr_indices: set of subaddress indices to use for transfer or
                             sweeping. if set empty, all are chosen when
                             sweeping, and one or more are automatically
                             chosen when transferring. after execution, returns
                             the set of actually used indices
            priority:

        Returns:
            PendingTransaction object.
            caller is responsible to check PendingTransaction::status()
            after object returned
        """
        cdef c_PendingTransaction *pt
        cdef string c_payment_id
        if payment_id is None:
            c_payment_id = b""
        else:
            c_payment_id = payment_id
        pt = self.o.createTransaction(dst_addr, c_payment_id, amount,
                                        mixin_count, priority,
                                        subaddr_account, subaddr_indices)
        return PendingTransaction.from_ptr(pt)

    def create_sweep_unmixable_transaction(self):
        cdef c_PendingTransaction *pt
        with nogil:
            pt = self.o.createSweepUnmixableTransaction()

        if pt is NULL:
            return None
        return PendingTransaction.from_ptr(pt)

    def restore_multisig_transaction(self, signData):
        cdef c_PendingTransaction* pt
        pt = self.o.restoreMultisigTransaction(signData)

    def import_key_images(self, string filename):
        cdef bint r
        with nogil:
            r = self.o.importKeyImages(filename)
        return r

    def daemon_blockchain_height(self):
        """
        Returns daemon blockchain height

        Returns:
            0 - in case error communicating with the daemon.
            status() will return Status_Error and
            error_string() will return verbose error description
        """
        cdef uint64_t r
        with nogil:
            r = self.o.daemonBlockChainHeight()
        return r

    def daemon_blockchain_target_height(self):
        """
        Returns daemon blockchain target height

        Returns:
            0 - in case error communicating with the daemon.
            status() will return Status_Error and
            errorString() will return verbose error description
        """
        cdef uint64_t r
        with nogil:
            r = self.o.daemonBlockChainTargetHeight()
        return r

    def synchronized(self):
        """
        checks if wallet was ever synchronized
        """
        cdef bint r
        with nogil:
            r = self.o.synchronized()
        return r

    @staticmethod
    def display_amount(amount):
        return c_Wallet.displayAmount(amount)

    @staticmethod
    def amount_from_string(amount):
        return c_Wallet.amountFromString(amount)

    @staticmethod
    def amount_from_double(amount):
        return c_Wallet.amountFromDouble(amount)

    @staticmethod
    def gen_payment_id():
        return c_Wallet.genPaymentId()

    @staticmethod
    def payment_id_valid(payment_id):
        return c_Wallet.paymentIdValid(payment_id)

    @staticmethod
    def service_node_pubkey_valid(s):
        """
        Check if the string represents a valid public key (regardless of
        whether the service node actually exists or not)
        """
        return c_Wallet.serviceNodePubkeyValid(s)

    @staticmethod
    def address_valid(s, c_NetworkType nettype):
        return c_Wallet.addressValid(s, nettype)

    @staticmethod
    def key_valid(secret_key_string, address_string, is_view_key, nettype):
        cdef string error
        r = c_Wallet.keyValid(secret_key_string, address_string, is_view_key, nettype, error)
        return r, error

    @staticmethod
    def payment_id_from_address(s, nettype):
        return c_Wallet.paymentIdFromAddress(s, nettype)

    @staticmethod
    def maximum_allowed_amount():
        return c_Wallet.maximumAllowedAmount()

    def start_refresh(self):
        """
        Start/resume refresh thread (refresh every 10 seconds)
        """
        with nogil:
            self.o.startRefresh()

    def pause_refresh(self):
        """
        Pause refresh thread
        """
        with nogil:
            self.o.pauseRefresh()

    def refresh(self):
        """
        Refreshes the wallet, updating transactions from daemon

        Returns:
            True if refreshed successfully
        """
        cdef bint r
        with nogil:
            r = self.o.refresh()
        return r

    def refresh_async(self):
        """
        Refreshes wallet asynchronously.
        """
        with nogil:
            self.o.refreshAsync()

    def rescan_blockchain(self):
        """
        Rescans the wallet, updating transactions from daemon

        Returns:
            True if refreshed successfully
        """
        cdef bint r
        with nogil:
            r = self.o.rescanBlockchain()
        return r

    def rescan_blockchain_async(self):
        """
        Rescans wallet asynchronously, starting from genesys
        """
        with nogil:
            self.o.rescanBlockchainAsync()

    def set_auto_refresh_interval(self, millis):
        """
        Setup interval for automatic refresh.

        Args:
            seconds: interval in millis.
                     if zero or less than zero - automatic refresh disabled
        """
        self.o.setAutoRefreshInterval(millis)

    def auto_refresh_interval(self):
        """
        Returns automatic refresh interval in millis
        """
        return self.o.autoRefreshInterval()

    # TODO:
    ##*!
    ##* \brief submitTransaction - submits transaction in signed tx file
    ##* \return                  - true on success
    ##*/
    #def submit_transaction(fileName)
    # bool submitTransaction(const std::string &fileName) = 0;


    ##/*!
    ## * \brief disposeTransaction - destroys transaction object
    ## * \param t -  pointer to the "PendingTransaction" object. Pointer is not valid after function returned;
    ## */
    #virtual void disposeTransaction(PendingTransaction * t) = 0;

    ## * \brief Estimates transaction fee.
    ## * \param destinations Vector consisting of <address, amount> pairs.
    ## * \return Estimated fee.
    ## */
    #virtual uint64_t estimateTransactionFee(const std::vector<std::pair<std::string, uint64_t>> &destinations,
    #                                        PendingTransaction::Priority priority) const = 0;

    def default_mixin(self):
        """
        Get number of mixins used in transactions
        """
        return self.o.defaultMixin()

    def set_default_mixin(self, arg):
        """
        Set the number of mixins to be used for new transactions
        """
        return self.o.setDefaultMixin(arg)

    def set_user_note(self, txid, note):
        """
        Attach an arbitrary string note to a txid

        Args:
            txid: the transaction id to attach the note to
            note: the note

        Returns:
            Return True if successful, False otherwise
        """
        return self.o.setUserNote(txid, note)

    def get_user_note(self, txid):
        """
        Get an arbitrary string note attached to a txid

        Args:
            txid: the transaction id to get the note from

        Returns:
            The attached note, or empty string if there is none
        """
        return self.o.getUserNote(txid)

    def get_default_data_dir(self):
        return self.o.getDefaultDataDir()

    def history(self):
        cdef c_TransactionHistory *h
        with nogil:
            h = self.o.history()
        if h is NULL:
            return None
        return TransactionHistory.from_ptr(h)

    @staticmethod
    def log_init(arg0, def_log_basename, string log_path=b'', bint console=True):
        c_Wallet.log_init(arg0, def_log_basename, log_path, console)

    def set_listener(self, listener):
        # cdef c_WalletListener *l
        # self.__listener = listener
        cy_set_listener(self.o, listener)

    def add_subaddress_account(self, string label):
        with nogil:
            self.o.addSubaddressAccount(label)

    def add_subaddress_account(self, string label):
        with nogil:
            self.o.addSubaddressAccount(label)

    def num_subaddress_accounts(self):
        cdef int r
        with nogil:
            r = self.o.numSubaddressAccounts()
        return r

    def num_subaddresses(self, uint32_t account_index):
        cdef int r
        with nogil:
            r = self.o.numSubaddresses(account_index)
        return r

    def add_subaddress(self, uint32_t accountIndex, string label):
        with nogil:
            self.o.addSubaddress(accountIndex, label)

    def get_subaddress_label(self, uint32_t accountIndex,
                              uint32_t addressIndex):
        cdef string r
        with nogil:
            r = self.o.getSubaddressLabel(accountIndex, addressIndex)
        return r

    def set_subaddress_label(self, uint32_t accountIndex,
                             uint32_t addressIndex, string label):
        with nogil:
            self.o.setSubaddressLabel(accountIndex, addressIndex, label)

    def get_bytes_received(self):
        cdef uint64_t r
        with nogil:
            r = self.o.getBytesReceived()
        return r

    def get_bytes_sent(self):
        cdef uint64_t r
        with nogil:
            r = self.o.getBytesSent()
        return r

    @staticmethod
    cdef Wallet from_ptr(void *o):
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef Wallet wrapper = Wallet.__new__(Wallet)
        wrapper.o = <c_Wallet*>o
        #wrapper.ptr_owner = owner
        return wrapper
