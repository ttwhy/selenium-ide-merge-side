# selenium-ide-merge-side
Merge [Selenium IDE](https://github.com/SeleniumHQ/selenium-ide) Side files together based on conventions.

Basic though for this helper, as side files does not allow includes of files / libraries you still could separate basic functionality (side objects) within a "base" file which will be used as your starting point for all tests. You could invoke the "function tests" using the run command, and on this way write reusable / updatable tests with selenium IDE even if you need to change some base functionality.

## Usage
Write Tests based on a Base.side file as starting point.
Functions that should be shared should contain a "~" char / tests does not contain that char.
Use the run command on ever reusable "~" fragment.

If you need to update your test, based on an updated base.side file, run the following command:


### Update a Test
~~~
./merge-side.sh -b base.side -t testToBeUpdated.side -o target.side
~~~

# Requirements
You need to install "*jq*" to parse json 
