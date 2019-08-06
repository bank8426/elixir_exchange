# ElixirExchange

> Elixir code challenge for backend go.exchange


## Getting started
### Step 1
To run this project, you need to install the following dependencies:

* [Elixir](https://elixir-lang.org/install.html)

### Step 2
To get started, run the following commands in project folder:

```shell
git clone https://github.com/bank8426/elixir_exchange.git # to clone this project
cd elixir_exchange
mix deps.get  # to installs the dependencies
```

### Step 3
After that, start Interactive Elixir mode.
```shell
iex -S mix #run interactive elixir with compiled all dependencies
```

### Step 4
In Interactive Elixir mode, run this command to process order list(input JSON file) in to order book(output JSON file).
```shell
ElixirExchange.Exchange.process_orders_json("path/to/input.json")
```
<b>Example</b>
<br>
I process input_1.json in "priv" folder.(there're 4 example files contain in it)<br>
If everything work correctly, it's will response with :ok 
<br>
<img src="https://drive.google.com/uc?id=1m4WIOuaJoynhXi8EJ4KlqnGK_nCkppKE" width="600" alt="loading"/>
<br>



In project folder will appear output.json which contains the order book result
<br>
<img src="https://drive.google.com/uc?id=14bcU_cGMkTydRWQQXbIf_XI0gzZG713b" width="600" alt="loading"/>
<br>
output.json
<br>
<img src="https://drive.google.com/uc?id=1JVQ1c-j2d2YNbaMG4q5Wakd8lb69A5RS" width="234" alt="loading"/>

## Tests

To run tests for this project,run this command in terminal:

```shell
mix test
```

To run tests for this project will code coverage report,run this command in terminal:

```shell
mix test --cover
```

## What have done by days. 
<ul>
  <li>
    <b>Day 1</b>
    <ul>
      <li>
        Read file and parse to JSON
      </li>
    </ul>
  </li>
  <li>
    <b>Day 2</b>
    <ul>
      <li>
        Process data by sum the same price
      </li>
      <li>
        Create helper module contain sorting funtion(ascending and descending)
      </li>
      <li>
        Write output json to file
      </li>
    </ul>
  </li>
  <li>
    <b>Day 3</b>
    <ul>
      <li>
        Handle partial matching
      </li>
      <li>
        Handle same order price matching
      </li>
    </ul>
  </li>
  <li>
    <b>Day 4</b>
    <ul>
      <li>
        Fix floating point calculation error by add helper functions for calculate float value with Decimal library 
      </li>
      <li>
        Replace Poison with Jason,fix ordering JSON
      </li>
      <li>
        Fix output format to contain "price" and "volume"
      </li>
    </ul>
  </li>
  <li>
    <b>Day 5</b>
    <ul>
      <li>
        Fix map in testing
      </li>
      <li>
        Refactor code
      </li>
    </ul>
  </li>
  <li>
    <b>Day 6</b>
    <ul>
      <li>
        Remove unused and Styling code
       </li>
      <li>
        Refactor code
       </li>
      <li>
        Fix bug and make test coverage 100%
      </li>
    </ul>
  </li>
  <li>
    <b>Day 7</b>
    <ul>
      <li>
        Add test cases for matching and helper functions.
      </li>
    </ul>
  </li>
  <li>
    <b>Day 8</b>
    <ul>
      <li>
        Change exchange fn name to process_orders_json
      </li>
      <li>
        Update README.md
      </li>
    </ul>
  </li>
</ul>
