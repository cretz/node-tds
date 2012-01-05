---
title: node-tds
layout: default
---


node-tds
========

This is a module that allows you to access Microsoft SQL Server 2005 and later.

It is a pure JS implementation of the [TDS protocol](http://msdn.microsoft.com/en-us/library/dd304523.aspx) hosted on [GitHub](http://github.com/cretz/node-tds).

Features
--------

* Connection/Statement execution model
* Parameterized statements
* Prepared (server-side) statements
* Common data type support
* Query cancellation
* Transactions

Installation
------------

To install, simply use npm (add -g to install globally):

```
npm install tds
```

Usage
=====

Quick Start
-----------

Require the module:

{% highlight javascript %}
var tds = require('tds');
{% endhighlight %}

Create a connection with parameters:

{% highlight javascript %}
var conn = new tds.Connection({
  host: 'localhost',
  port: 1433,
  userName: 'sa',
  password: 'sapass'
})
{% endhighlight %}

This creates a connection to the given host and port with the given credentials. If a host and/or port are not provided, they are defaulted to 'localhost' and 1433 respectively. There are more options that can be passed into a connection that can be found in the appendix.

Now connect to the database providing a callback that can accept errors:

{% highlight javascript %}
conn.connect(function(error) {
  if (error != null) {
    console.error('Received error', error);
  } else {
    console.log('Now connected, can start using');
  }
});
{% endhighlight %}

Once you have successfully connected, you can use the client for statements. Results of statements, error messages, info messages, etc can be sent as events or can be handled by a handler set as the handler property on the Connection property. Examples here show event handling. Handlers are discussed later.

To receive messages and errors on the connection itself when a statement isn't executing, listen for the events:

{% highlight javascript %}
conn.on('error', function(error) {
  console.error('Received error', error);
});
conn.on('message', function(message) {
  console.info('Received info', message);
});
{% endhighlight %}

Most of the time errors and messages will apply to a statement and that's where you should attach your listeners. If an error is an instance of TdsError, the info property will contain much more information. Error and message contents and details are discussed later.

Now create a statement after your connection callback has been called without an error:

{% highlight javascript %}
var stmt = conn.createStatement('SELECT 1');
{% endhighlight %}

The statement, like the connection, can either listen to events or supply a handler. This example will use events. The API also covers instantiating a Statement via its constructor instead of the createStatement function.

Statements have several features such as preparation, parameters, cancellation, etc. These will be covered in more detail later.

To retrieve this row, listen to the event and execute the statement:

{% highlight javascript %}
stmt.on('row', function(row) {
  console.log('Received row: ', row.getValue(0));
});
stmt.execute();
{% endhighlight %}

This will display the value 1 which is returned from getValue as an integer. Providing an integer to getValue gets the value of the column at that 0-based index. If a column name is supplied in the query, you can give that (case-sensitive) column name to getValue instead.

It is important to remember that only one statement can execute on a connection at a time. Attempting to execute another statement on a connection while one is already executing will result in an error. While a connection is open, a statement can be re-executed any number of times.

Other events can be listened to on a statement such as 'error', 'message', 'metadata' and 'done'. The error and message events are the same as they are on the connection, they are just delegated to the statement instead. The metadata event provides column metadata before any row is executed. The done event gives information about the row count among other things.

To end the connection, simply call end on the connection:

{% highlight javascript %}
conn.end();
{% endhighlight %}

Parameterized Statements
------------------------

Statements can be parameterized in native SQL Server form to make statements easier to use and to help prevent injection attacks. To create a statement with parameters, provide a parameter object containing type information:

{% highlight javascript %}
var stmt = conn.createStatement('SELECT @Param1 AS Value1, @Param2 AS Value2', {
  Param1: { type: 'VarChar', size: 7 },
  Param2: { type: 'Int' }
});
{% endhighlight %}

This creates a parameterized statement with two parameters. The types provided are SQL Server data types (case insensitive). Types with lengths should have 'size' specified or they will use the default SQL Server length. Similarly, types with precision and scale should have 'precision' and 'scale' provided or they'll use the default also. For things like VarChar, obviously the 'size' can well exceed the length of the actual value.

Now, to execute with the parameters, simply pass them into execute:

{% highlight javascript %}
stmt.on('row', function(row) {
  console.log('Got values:', row.getValue('Value1'), row.getValue('Value2'));
});
stmt.execute({Param1: 'myval', Param2: 15});
{% endhighlight %}

This will output 'myval' and 15 as the resulting row.

Preparing Statements
--------------------

SQL server can prepare a statement on the server side so it can be re-executed many times. Many DBA's frown on this approach due to the caller's misuse of server-side prepared statements. There are two basic rules to using server-side prepared statements: 1) ALWAYS unprepare the statement when it is no longer used and 2) only use prepared statements if you execute the statement MANY times.

Assume we have the same statement we had above with the same row listener:

{% highlight javascript %}
var stmt = conn.createStatement('SELECT @Param1 AS Value1, @Param2 AS Value2', {
  Param1: { type: 'VarChar', size: 7 },
  Param2: { type: 'Int' }
});
stmt.on('row', function(row) {
  console.log('Got values:', row.getValue('Value1'), row.getValue('Value2'));
});
{% endhighlight %}

Now, instead of calling execute, we will prepare it and pass a callback which can accept an error:

{% highlight javascript %}
stmt.prepare(function(error) {
  if (error != null) {
    console.error('Received error', error);
  } else {
    console.log('Prepared statement ready to use');
  }
});
{% endhighlight %}

Once the callback has been executed without error, the execute function can be used as normal:

{% highlight javascript %}
stmt.execute({Param1: 'myval', Param2: 15});
{% endhighlight %}

This will output 'myval' and 15 just as the normal, non-prepared statement did. Once you are done using the prepared statement, you MUST call unprepare with a callback:

{% highlight javascript %}
stmt.unprepare(function(error) {
  if (error != null) {
    console.error('Received error', error);
  } else {
    console.log('Statement properly unprepared');
  }
});
{% endhighlight %}

Query Cancellation
------------------

Sometimes, you may want to cancel a long running statement. This can be done simply with cancel:

{% highlight javascript %}
stmt.cancel();
{% endhighlight %}

To know whether the statement is cancelled do as you would to know whether any statement execution is complete, listen to the 'done' event.

Transactions
------------

By default, the connection is in auto-commit mode. This means any INSERT or UPDATE will commit automatically. This can be turned off. Call setAutoCommit with false and a callback (while a statement is not executing) to require manual commits:

{% highlight javascript %}
conn.setAutoCommit(false, function(error) {
  if (error != null) {
    console.error('Received error', error);
  } else {
    console.log('Connection now in manual-commit mode');
  }
});
{% endhighlight %}

Now, regardless of what statements are executed, you can rollback or commit them:

{% highlight javascript %}
var stmt = conn.createStatement("INSERT INTO TestTable VALUES ('TestValue')");
stmt.on('done', function(done) {
  if (iWantToRollback) {
    conn.rollback(function(error) {
      if (error != null) {
        console.error('Rollback failed', error);
      } else {
        console.log('Successfully rolled back');
      }
    });
  } else {
    conn.commit(function(error) {
      if (error != null) {
        console.error('Commit failed', error);
      } else {
        console.log('Successfully committed');
      }
    });
  }
});
{% endhighlight %}

Instantiating a Statement
-------------------------

Instead of:

{% highlight javascript %}
var stmt = conn.createStatement('SELECT @Val', {Val: {type: 'Int'}});
{% endhighlight %}

you can:

{% highlight javascript %}
var stmt = new tds.Statement(conn, 'SELECT @Val', {Val: {type: 'Int'}});
{% endhighlight %}

Using Handlers
--------------

Handlers can be used instead of events for connections and statements. When handlers are provided, events are NOT triggered. For a connection, simply set the handler property:

{% highlight javascript %}
conn.handler = {
  error: function(error) {
    console.error('Received error', error);
  },
  message: function(message) {
    console.info('Received message', message);
  }
}
{% endhighlight %}

To use a handler on a statement you can do it one of three ways:

{% highlight javascript %}
//1. as the last param to createStatement (after params)
var stmt = conn.createStatement('SELECT 1', null, {
  row: function(row) {
    console.log('Got row');    
  }
});
//2. as the last param to the Statement constructor (after params)
var stmt = new Statement(conn, 'SELECT 1', null, {
  row: function(row) {
    console.log('Got row');    
  }
});
//3. as the handler property on the Statement object
var stmt = conn.createStatement('SELECT 1');
stmt.handler = {
  row: function(row) {
    console.log('Got row');    
  }
};
{% endhighlight %}

Done Event
----------

A done event (or handler function) is triggered when a query is complete. It contains a parameter that has a couple of properties:

* isError - true if error on this statement
* hasRowCount - true if the rowCount is valid on this object
* rowCount - The number of affected on the statement

Appendices
==========

Column Metadata
---------------

Column metadata can be obtained one of three ways: 1) by listening to the 'metadata' event on the statement, 2) by using the metadata property of the statement, or 3) by using the metadata property of the row. The metadata event is triggered before any rows in the result set. Multiple metadata events may be triggered per statement execution.

The metadata object:

* columns - ordered array of column objects
* columnsByName - object containing column objects keyed by the (case-sensitive) column name
* getColumn(column) - retrieves a column based on the passed in index or (case-sensitive) column name

The column object:

* index - the 0-based column index
* type - the column's type object (see below)
* length - the column value's length (not necessarily each row's length)
* isNullable - boolean for whether the column's value can be null
* isCaseSensitive - boolean for whether the column's string value is case-sensitive
* name - the column's name

The column's type object:

* name - the all caps type name as shown in the TDS spec (not really that useful)
* sqlType - the SQL Server data type name
* length - the static byte length of the type if applicable (e.g. Int is 4)
* emptyPossible - if present and true, this type can have an empty value (e.g. Int won't have this value because it can't be empty, but a VarChar can)

Example:

{% highlight javascript %}
stmt.on('metadata', function(metadata) {
  for (column in metadata.columns) {
    console.log('Name: %s, Index: %d', column.name, column.index);
  }
});
{% endhighlight %}

Connection Options
------------------

The options object passed to the constructor can take several different values. In the example above we use 'host', 'port', 'userName', and 'password'. Here is the full list of options:

* appName - The name of this application/client as it will appear to SQL server. Defaults to 'node-tds'
* database - The database to default to on login. Defaults to user's default database
* domain - The user's Windows domain. Not currently supported
* host - The host of the SQL server. Defaults to 'localhost'
* password - The password for the SQL server user
* port - The port of the SQL server. Defaults to 1433
* tdsVersion - The (not yet exposed) TDS protocol version to use
* userName - Required username for the SQL server user

Errors and Messages
-------------------

Errors are represented as an instance of require('tds').TdsError which extends the native node.js Error. It contains an info object with detail about the error. This detail has the same contents as a message object. The properties:

* error - true if it is an error's info, false if it is a message
* lineNumber - the lineNumber of the error/message
* number - the SQL Server error/message number
* procName - the stored procedure name if applicable
* serverName - the name of the SQL server
* severity - the SQL Server [severity](http://msdn.microsoft.com/en-us/library/ms164086.aspx) of the error/message
* text - the text contents of the error/message

Special Data Types
------------------

### BigInt

BigInt data types cannot be properly represented in JavaScript, so it is provided as a string. This means a string can be used to pass it in (but can also be an integer) and that a string is the ONLY way it is retrieved. You can use a library such as [node-bigint](https://github.com/substack/node-bigint) or [bigdecimal.js](https://github.com/iriscouch/bigdecimal.js) to help in handling this.

### Binary and VarBinary

This is represented as a buffer both ways. This means you pass it in as a buffer and it is retrieved as a buffer.

TODO
----

Things that need to be done on this project or would be nice to do:

* Implement 'end' event on the connection
* Implement Numeric/Decimal
* Document usage with node-pool
* Implement wrappers for common node.js DB abstractions
* Support domain-based authentication (NTLM)
* Support native SSO authentication using the current user (Windows only; would be nice when node-ffi has Windows support; a.k.a. SSPI)
* More docs/tests on multiple result sets in a single statement
* Support SQL 2008 types (date, time, datetime2, datetimeoffset, uniqueidentifier)
* More docs, API docs, cleaner docs
* More/better tests

Fun stuff:

* TDS server implementation (could be good for SQL Server proxies)
* Use JS-to-CLR compiler to make creation of triggers, stored procedures, and datatypes in javascript possible (just sounds like fun)