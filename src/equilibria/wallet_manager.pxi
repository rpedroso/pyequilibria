# distutils: language = c++
# cython: c_string_type=unicode, c_string_encoding=utf8

from libc.stdint cimport uint64_t, uint32_t, uint8_t
from .wallet_api cimport (
        c_NetworkType, c_Wallet, c_WalletListener,
        c_LogLevel, c_Status,
        )
#from .wallet_api cimport Status_Ok
# from . cimport wallet


cdef class WalletManager:
    cdef c_WalletManager *o
    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")

    def create_wallet(self, string path, string password, string language,
                        c_NetworkType nettype, uint64_t kdf_rounds = 1):
        """
        Creates new wallet

        Args:
            path:       Name of wallet file
            password:   Password of wallet file
            language:   Language to be used to generate electrum seed mnemonic
            nettype:    Network type
            kdf_rounds: Number of rounds for key derivation function

        Returns:
            Wallet instance (Wallet.status() needs to be called to check if created successedfully)
        """

        cdef c_Wallet *w

        with nogil:
            w = self.o.createWallet(path, password, language, nettype, kdf_rounds)

        return Wallet.from_ptr(w)

    def open_wallet(self, string path, string password, c_NetworkType nettype,
                    uint64_t kdf_rounds = 1, listener = None):
        """
        Opens existing wallet

        Args:
            path:       Name of wallet file
            password:   Password of wallet file
            nettype:    Network type
            kdf_rounds: Number of rounds for key derivation function
            listener:   Wallet listener to set to the wallet after creation

        Returns:
            Wallet instance (Wallet.status() needs to be called to check if opened successfully)

        """
        cdef:
            c_Wallet *w
            c_WalletListener *c_listener

        with nogil:
            w = self.o.openWallet(path, password, nettype, kdf_rounds, NULL)

        if listener is not None:
            cy_set_listener(w, listener)

        return Wallet.from_ptr(w)

    def recovery_wallet(self, string &path, string &password,
                        string &mnemonic,
                        c_NetworkType nettype=c_NetworkType.MAINNET,
                        uint64_t restoreHeight=0,
                        uint64_t kdf_rounds=1,
                        string &seed_offset=b""):
        """
        Recovers existing wallet using mnemonic (electrum seed)

        Args:
            path:          Name of wallet file to be created
            password:      Password of wallet file
            mnemonic:      mnemonic (25 words electrum seed)
            nettype:       Network type
            restoreHeight: restore from start height
            kdf_rounds:    Number of rounds for key derivation function
            seed_offset:   Seed offset passphrase (optional)

            Returns:
                Wallet class instance already opened
                (Wallet.status() needs to be called to check if recovered successfully)
        """

        with nogil:
            w = self.o.recoveryWallet(path, password, mnemonic, nettype,
                                        restoreHeight, kdf_rounds, seed_offset)

        return Wallet.from_ptr(w)

    def create_wallet_from_keys(self, string path, string password,
                                string language, c_NetworkType nettype,
                                uint64_t restoreHeight, string addressString,
                                string viewKeyString,
                                string spendKeyString = b"",
                                uint64_t kdf_rounds = 1):
        """
        recovers existing wallet using keys. Creates a view only wallet if spend key is omitted

        Args:
            path:           Name of wallet file to be created
            password:       Password of wallet file
            language:       language
            nettype:        Network type
            restoreHeight:  restore from start height
            addressString:  public address
            viewKeyString:  view key
            spendKeyString: spend key (optional)
            kdf_rounds:     Number of rounds for key derivation function

        Returns:
            Wallet instance (Wallet.status() needs to be called to check if recovered successfully)

        """
        cdef c_Wallet *w

        with nogil:
            w = self.o.createWalletFromKeys(path, password, language, nettype,
                                            restoreHeight, addressString,
                                            viewKeyString, spendKeyString,
                                            kdf_rounds)
        return Wallet.from_ptr(w)

    def close_wallet(self, Wallet wallet, bint store=True):
        """
        Closes wallet. In case operation succeeded, wallet object deleted.
        In case operation failed, wallet object not deleted

        Args:
            previously opened / created wallet instance

        Returns:
            None
        """
        cdef bint r
        cdef c_Wallet *w

        w = wallet.o
        with nogil:
            r = self.o.closeWallet(w, store)
            wallet.o = NULL

        return r

    def wallet_exists(self, string path):
        """
        check if the given filename is the wallet

        Args:
            path: filename

        Returns:
            True if wallet exists
        """
        cdef bint r
        with nogil:
            r = self.o.walletExists(path)
        return r


    def verify_wallet_password(self, string keys_file_name,
            string password, bint no_spend_key, uint64_t kdf_rounds = 1):
        """
        check if the given filename is the wallet

        Args:
            keys_file_name - location of keys file
            password - password to verify
            no_spend_key - verify only view keys?
            kdf_rounds - number of rounds for key derivation function

        Returns:
            True if password is correct

        Note:
            This function will fail when the wallet keys file is opened
            because the wallet program locks the keys file.
            In this case, Wallet.unlockKeysFile() and Wallet.lockKeysFile()
            need to be called before and after the call to this function,
            respectively.
        """
        cdef bint r

        with nogil:
            r = self.o.verifyWalletPassword(keys_file_name, password,
                                        no_spend_key, kdf_rounds)
        return r

    def find_wallets(self, string path):
        """
        Searches for the wallet files by given path name recursively

        Args:
            path: starting point to search

        Returns:
            Generator of strings with found wallets (absolute paths).
        """
        cdef vector[string] w_list

        with nogil:
            w_list = self.o.findWallets(path)

        for w in w_list:
            yield w

    # returns verbose error string regarding last error
    def error_string(self):
        """
        Returns:
            Verbose error string regarding last error
        """
        return self.o.errorString()

    def set_daemon_address(self, string address):
        """
        Set the daemon address (hostname and port)
        
        Args:
            address: Daemon address ("ip:port")

        Returns:
            None
        """
        with nogil:
            self.o.setDaemonAddress(address)

    def connected(self):
        """
        Whether the daemon can be reached.

        Returns:
            Tupple (True, version number) or (False, 0)
        """
        cdef:
            bint r
            uint32_t version

        with nogil:
            r = self.o.connected(&version)

        return (r, version) if r else (r, <uint32_t>0)

    def blockchain_height(self):
        """
        Returns:
            Current blockchain height
        """
        cdef:
            uint64_t r

        with nogil:
            r = self.o.blockchainHeight()

        return r

    def blockchain_target_height(self):
        """
        Returns:
            Current blockchain target height
        """
        cdef uint64_t r
        with nogil:
            r = self.o.blockchainTargetHeight()
        return r

    def network_difficulty(self):
        """
        Returns current network difficulty
        """
        cdef uint64_t r

        with nogil:
            r = self.o.networkDifficulty()

        return r

    def mining_hash_rate(self):
        """
        Returns:
            Current mining hash rate (0 if not mining)
        """
        cdef double r
        with nogil:
            r = self.o.miningHashRate()
        return r

    def block_target(self):
        """
        Returns:
            current block target
        """
        cdef uint64_t r
        with nogil:
            r = self.o.blockTarget()
        return r

    def is_mining(self):
        """
        Returns:
            True if mining
        """
        cdef bint r
        with nogil:
            r = self.o.isMining()
        return r


cpdef enum class _LogLevel:
    Silent  = c_LogLevel.LogLevel_Silent
    L0      = c_LogLevel.LogLevel_0 
    L1      = c_LogLevel.LogLevel_1 
    L2      = c_LogLevel.LogLevel_2 
    L3      = c_LogLevel.LogLevel_3 
    L4      = c_LogLevel.LogLevel_4 
    Min     = c_LogLevel.LogLevel_Min
    Max     = c_LogLevel.LogLevel_Max

cdef class WalletManagerFactory:
    LogLevel = _LogLevel

    def __init__(self):
        # Prevent accidental instantiation from normal Python code
        # since we cannot pass a struct pointer into a Python constructor.
        raise TypeError("This class cannot be instantiated directly.")


    @staticmethod
    def get_wallet_manager():
        cdef c_WalletManager *wm = c_WalletManagerFactory.getWalletManager()
        return WalletManager_from_ptr(wm)

    @staticmethod
    def set_log_level(int level):
        """
        logging levels for underlying library

        Args:
            level: LogLevel_Silent = -1
                   LogLevel_0      = 0
                   LogLevel_1      = 1
                   LogLevel_2      = 2
                   LogLevel_3      = 3
                   LogLevel_4      = 4
                   LogLevel_Min    = LogLevel_Silent
                   LogLevel_Max    = LogLevel_4

        """
        with nogil:
            c_WalletManagerFactory.setLogLevel(level)

    @staticmethod
    def set_log_categories(string categories):
        with nogil:
            c_WalletManagerFactory.setLogCategories(categories)


#    @staticmethod
cdef WalletManager WalletManager_from_ptr(void *o):
        # Fast call to __new__() that bypasses the __init__() constructor.
        cdef WalletManager wrapper = WalletManager.__new__(WalletManager)
        wrapper.o = <c_WalletManager*>o
        #wrapper.ptr_owner = owner
        return wrapper

