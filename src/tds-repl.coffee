{Connection} = require 'tds'
program = require 'commander'

program.usage('[options]').
        option('-U <login_id>', 'The user login ID').
        option('-P <password>', 'The password').
        option('-S <server>', 'Server in form - [protocol:]server[\\instance_name][,port]').
        option('-d <database>', 'Initial database').
        option('-i <files>', 'Input files, comma delimited, sans spaces').
        option('-o <output_file>', 'Output file').
        option('-q <query>', 'Query without exit').
        option('-Q <query>', 'Query and exit').
        option('-v <var>', 'Variable').
        parse(process.argv)

# TODO - replicate sqlcmd functionality