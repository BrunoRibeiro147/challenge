# HorizonChallenge

Resolution of the [challenge](https://gist.github.com/noverloop/86c4993b16f589637d06e66a04f4a6c2), the ideia is be able to receive an array of products codes and be able to apply promotion on them

## Installation

  * Clone the project
  * Run `mix deps.get` its gonna download the dependencies
  * Start application using `iex -S mix`
  
## Usage
   
   * You can use the simple interface to scan items: 
   
   ```elixir
   # pricing_rules = Array of codes of the existents promotions
   
   pricing_rules = [1]
   
   co = Checkout.new(pricing_rules)
   
   co.scan("VOUCHER")
   co.scan("VOUCHER")
   co.scan("TSHIRT")
   
   co.total
   
   # €25.00
   ```
