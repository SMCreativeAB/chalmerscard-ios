import Foundation

public class CardRepository {
    static let keychainKey = "CHALMERS_CARD"
    static let lastStatementKey = "CHALMERS_CARD_STATEMENT"
    let defaults = UserDefaults.init(suiteName: "group.chalmersCard")
    var keychain: StorageProtocol
    let api: CardDataProtocol
    
    public init(keychain: StorageProtocol, api: CardDataProtocol) {
        self.keychain = keychain
        self.api = api
    }
    
    public func getStatement(_ callback: @escaping (CardStatement?) -> Void) {
        if let number = getNumber() {
            api.getCardAmount(number) { amount in
                self.onCardAmount(amount, callback: callback)
            }
        } else {
            callback(nil)
        }
    }
    
    fileprivate func onCardAmount(_ amount: Int?, callback: (CardStatement?) -> Void) {
        if let amountValue = amount {
            let cardStatement = CardStatement(balance: amountValue, timestamp: Date())
            let statementData = NSKeyedArchiver.archivedData(withRootObject: cardStatement)
            self.defaults!.set(statementData, forKey: CardRepository.lastStatementKey)
            callback(cardStatement)
        } else {
            callback(nil)
        }
    }
    
    public func getNumber() -> String? {
        return keychain.get(CardRepository.keychainKey)
    }
    
    public func getLastStatement() -> CardStatement? {
        if let data = defaults!.object(forKey: CardRepository.lastStatementKey) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? CardStatement
        }
        
        return nil
    }
    
	public func exists() -> Bool {
        return getNumber() != nil
    }
    
    public func set(_ number: String) {
        keychain.set(CardRepository.keychainKey, value: number)
    }
}
