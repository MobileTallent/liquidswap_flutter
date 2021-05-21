///
//  Generated code. Do not modify.
//  source: sideswap.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

const Empty$json = const {
  '1': 'Empty',
};

const Address$json = const {
  '1': 'Address',
  '2': const [
    const {'1': 'addr', '3': 1, '4': 2, '5': 9, '10': 'addr'},
  ],
};

const Balance$json = const {
  '1': 'Balance',
  '2': const [
    const {'1': 'ticker', '3': 1, '4': 2, '5': 9, '10': 'ticker'},
    const {'1': 'amount', '3': 2, '4': 2, '5': 3, '10': 'amount'},
  ],
};

const Asset$json = const {
  '1': 'Asset',
  '2': const [
    const {'1': 'asset_id', '3': 1, '4': 2, '5': 9, '10': 'assetId'},
    const {'1': 'name', '3': 2, '4': 2, '5': 9, '10': 'name'},
    const {'1': 'ticker', '3': 3, '4': 2, '5': 9, '10': 'ticker'},
    const {'1': 'icon', '3': 4, '4': 2, '5': 9, '10': 'icon'},
    const {'1': 'precision', '3': 5, '4': 2, '5': 13, '10': 'precision'},
  ],
};

const Transaction$json = const {
  '1': 'Transaction',
  '2': const [
    const {'1': 'txid', '3': 1, '4': 2, '5': 9, '10': 'txid'},
    const {'1': 'balances', '3': 2, '4': 3, '5': 11, '6': '.sideswap.proto.Balance', '10': 'balances'},
    const {'1': 'created_at', '3': 3, '4': 2, '5': 9, '10': 'createdAt'},
    const {'1': 'block_height', '3': 4, '4': 2, '5': 13, '10': 'blockHeight'},
    const {'1': 'memo', '3': 5, '4': 2, '5': 9, '10': 'memo'},
  ],
};

const ServerStatus$json = const {
  '1': 'ServerStatus',
  '2': const [
    const {'1': 'min_peg_in_amount', '3': 1, '4': 2, '5': 3, '10': 'minPegInAmount'},
    const {'1': 'min_peg_out_amount', '3': 2, '4': 2, '5': 3, '10': 'minPegOutAmount'},
    const {'1': 'server_fee_percent_peg_in', '3': 3, '4': 2, '5': 1, '10': 'serverFeePercentPegIn'},
    const {'1': 'server_fee_percent_peg_out', '3': 4, '4': 2, '5': 1, '10': 'serverFeePercentPegOut'},
  ],
};

const To$json = const {
  '1': 'To',
  '2': const [
    const {'1': 'login', '3': 1, '4': 1, '5': 11, '6': '.sideswap.proto.To.Login', '9': 0, '10': 'login'},
    const {'1': 'logout', '3': 2, '4': 1, '5': 11, '6': '.sideswap.proto.Empty', '9': 0, '10': 'logout'},
    const {'1': 'set_memo', '3': 10, '4': 1, '5': 11, '6': '.sideswap.proto.To.SetMemo', '9': 0, '10': 'setMemo'},
    const {'1': 'get_recv_address', '3': 11, '4': 1, '5': 11, '6': '.sideswap.proto.Empty', '9': 0, '10': 'getRecvAddress'},
    const {'1': 'create_tx', '3': 12, '4': 1, '5': 11, '6': '.sideswap.proto.To.CreateTx', '9': 0, '10': 'createTx'},
    const {'1': 'send_tx', '3': 13, '4': 1, '5': 11, '6': '.sideswap.proto.To.SendTx', '9': 0, '10': 'sendTx'},
    const {'1': 'swap_request', '3': 20, '4': 1, '5': 11, '6': '.sideswap.proto.To.SwapRequest', '9': 0, '10': 'swapRequest'},
    const {'1': 'swap_cancel', '3': 21, '4': 1, '5': 11, '6': '.sideswap.proto.Empty', '9': 0, '10': 'swapCancel'},
    const {'1': 'swap_accept', '3': 22, '4': 1, '5': 11, '6': '.sideswap.proto.Empty', '9': 0, '10': 'swapAccept'},
  ],
  '3': const [To_Login$json, To_SwapRequest$json, To_CreateTx$json, To_SendTx$json, To_SetMemo$json],
  '8': const [
    const {'1': 'msg'},
  ],
};

const To_Login$json = const {
  '1': 'Login',
  '2': const [
    const {'1': 'mnemonic', '3': 1, '4': 2, '5': 9, '10': 'mnemonic'},
  ],
};

const To_SwapRequest$json = const {
  '1': 'SwapRequest',
  '2': const [
    const {'1': 'send_ticker', '3': 1, '4': 2, '5': 9, '10': 'sendTicker'},
    const {'1': 'recv_ticker', '3': 2, '4': 2, '5': 9, '10': 'recvTicker'},
    const {'1': 'send_amount', '3': 3, '4': 1, '5': 3, '10': 'sendAmount'},
    const {'1': 'recv_addr', '3': 4, '4': 1, '5': 9, '10': 'recvAddr'},
  ],
};

const To_CreateTx$json = const {
  '1': 'CreateTx',
  '2': const [
    const {'1': 'addr', '3': 1, '4': 2, '5': 9, '10': 'addr'},
    const {'1': 'balance', '3': 2, '4': 2, '5': 11, '6': '.sideswap.proto.Balance', '10': 'balance'},
  ],
};

const To_SendTx$json = const {
  '1': 'SendTx',
  '2': const [
    const {'1': 'memo', '3': 1, '4': 2, '5': 9, '10': 'memo'},
  ],
};

const To_SetMemo$json = const {
  '1': 'SetMemo',
  '2': const [
    const {'1': 'txid', '3': 1, '4': 2, '5': 9, '10': 'txid'},
    const {'1': 'memo', '3': 2, '4': 2, '5': 9, '10': 'memo'},
  ],
};

const From$json = const {
  '1': 'From',
  '2': const [
    const {'1': 'new_tx', '3': 1, '4': 1, '5': 11, '6': '.sideswap.proto.From.NewTx', '9': 0, '10': 'newTx'},
    const {'1': 'new_asset', '3': 2, '4': 1, '5': 11, '6': '.sideswap.proto.Asset', '9': 0, '10': 'newAsset'},
    const {'1': 'balance_update', '3': 3, '4': 1, '5': 11, '6': '.sideswap.proto.Balance', '9': 0, '10': 'balanceUpdate'},
    const {'1': 'server_status', '3': 4, '4': 1, '5': 11, '6': '.sideswap.proto.ServerStatus', '9': 0, '10': 'serverStatus'},
    const {'1': 'swap_review', '3': 20, '4': 1, '5': 11, '6': '.sideswap.proto.From.SwapReview', '9': 0, '10': 'swapReview'},
    const {'1': 'swap_wait_tx', '3': 21, '4': 1, '5': 11, '6': '.sideswap.proto.From.SwapWaitTx', '9': 0, '10': 'swapWaitTx'},
    const {'1': 'swap_succeed', '3': 22, '4': 1, '5': 11, '6': '.sideswap.proto.From.SwapSucceed', '9': 0, '10': 'swapSucceed'},
    const {'1': 'swap_failed', '3': 23, '4': 1, '5': 9, '9': 0, '10': 'swapFailed'},
    const {'1': 'recv_address', '3': 30, '4': 1, '5': 11, '6': '.sideswap.proto.Address', '9': 0, '10': 'recvAddress'},
    const {'1': 'create_tx_result', '3': 31, '4': 1, '5': 11, '6': '.sideswap.proto.From.CreateTxResult', '9': 0, '10': 'createTxResult'},
    const {'1': 'send_result', '3': 32, '4': 1, '5': 11, '6': '.sideswap.proto.From.SendResult', '9': 0, '10': 'sendResult'},
  ],
  '3': const [From_NewTx$json, From_SwapReview$json, From_SwapWaitTx$json, From_SwapSucceed$json, From_CreateTxResult$json, From_SendResult$json],
  '8': const [
    const {'1': 'msg'},
  ],
};

const From_NewTx$json = const {
  '1': 'NewTx',
  '2': const [
    const {'1': 'txs', '3': 1, '4': 3, '5': 11, '6': '.sideswap.proto.Transaction', '10': 'txs'},
  ],
};

const From_SwapReview$json = const {
  '1': 'SwapReview',
  '2': const [
    const {'1': 'send_asset', '3': 1, '4': 2, '5': 9, '10': 'sendAsset'},
    const {'1': 'recv_asset', '3': 2, '4': 2, '5': 9, '10': 'recvAsset'},
    const {'1': 'created_at', '3': 3, '4': 2, '5': 3, '10': 'createdAt'},
    const {'1': 'expires_at', '3': 4, '4': 2, '5': 3, '10': 'expiresAt'},
    const {'1': 'send_amount', '3': 5, '4': 2, '5': 3, '10': 'sendAmount'},
    const {'1': 'recv_amount', '3': 6, '4': 2, '5': 3, '10': 'recvAmount'},
    const {'1': 'network_fee', '3': 7, '4': 2, '5': 3, '10': 'networkFee'},
    const {'1': 'server_fee', '3': 8, '4': 2, '5': 3, '10': 'serverFee'},
  ],
};

const From_SwapWaitTx$json = const {
  '1': 'SwapWaitTx',
  '2': const [
    const {'1': 'peg_addr', '3': 1, '4': 2, '5': 9, '10': 'pegAddr'},
    const {'1': 'recv_addr', '3': 2, '4': 1, '5': 9, '10': 'recvAddr'},
  ],
};

const From_SwapSucceed$json = const {
  '1': 'SwapSucceed',
  '2': const [
    const {'1': 'created_at', '3': 1, '4': 2, '5': 3, '10': 'createdAt'},
    const {'1': 'sent_amount', '3': 2, '4': 2, '5': 3, '10': 'sentAmount'},
    const {'1': 'recv_amount', '3': 3, '4': 2, '5': 3, '10': 'recvAmount'},
    const {'1': 'txid', '3': 4, '4': 2, '5': 9, '10': 'txid'},
    const {'1': 'recv_addr', '3': 5, '4': 1, '5': 9, '10': 'recvAddr'},
  ],
};

const From_CreateTxResult$json = const {
  '1': 'CreateTxResult',
  '2': const [
    const {'1': 'error_msg', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'errorMsg'},
    const {'1': 'network_fee', '3': 2, '4': 1, '5': 3, '9': 0, '10': 'networkFee'},
  ],
  '8': const [
    const {'1': 'result'},
  ],
};

const From_SendResult$json = const {
  '1': 'SendResult',
  '2': const [
    const {'1': 'error_msg', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'errorMsg'},
    const {'1': 'txid', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'txid'},
  ],
  '8': const [
    const {'1': 'result'},
  ],
};

