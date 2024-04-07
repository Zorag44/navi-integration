module strategy::strat{
    use std::option::{Self, Option};
    use std::vector;
    use std::type_name;
    use std::ascii;
    use std::string::{Self, String};
    use sui::clock::{Self, Clock};
    use sui::tx_context::{Self,TxContext};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::vec_map::{Self, VecMap};
    use sui::vec_set;
    use sui::math;
    use sui::event;
    use sui::package::UpgradeCap;
    use sui::linked_table::{Self, LinkedTable};
    use lending_core::lending;
    use oracle::oracle::{PriceOracle};
    use lending_core::pool::{Pool};
    use lending_core::account::{AccountCap};
    use lending_core::incentive::{Incentive as IncentiveV1};
    use lending_core::incentive_v2::{Self, Incentive};
    use lending_core::storage::{Storage};

    struct My_navi_account has key, store{
        id:UID,
        navi_account: AccountCap,
    }
    public fun create_navi_account( ctx: &mut TxContext){
        transfer::public_share_object(My_navi_account{
            id:object::new(ctx),
            navi_account: lending::create_account(ctx),
        })
    }
//deposit_with_account_cap<CoinType>(clock: &Clock, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, deposit_coin: Coin<CoinType>, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, account_cap: &AccountCap);
    public fun deposit<T>(navi_acc: &mut My_navi_account, clock: &Clock, storage: &mut Storage, pool: &mut Pool<T>, asset: u8, deposit_coin: Coin<T>, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive){
        incentive_v2::deposit_with_account_cap<T>(clock, storage, pool, asset, deposit_coin, incentive_v1, incentive_v2, &navi_acc.navi_account);
    }

//withdraw_with_account_cap<CoinType>(clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<CoinType>, asset: u8, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, account_cap: &AccountCap): Balance<CoinType>;
    public fun withdraw<T>(navi_acc: &mut My_navi_account, clock: &Clock, oracle: &PriceOracle, storage: &mut Storage, pool: &mut Pool<T>, asset: u8, amount: u64, incentive_v1: &mut IncentiveV1, incentive_v2: &mut Incentive, ctx: &mut TxContext){
        let balance = incentive_v2::withdraw_with_account_cap<T>(clock, oracle, storage, pool, asset, amount, incentive_v1, incentive_v2, &mut navi_acc.navi_account);
        transfer::public_transfer(coin::from_balance(balance, ctx), tx_context::sender(ctx));
    }

    

}