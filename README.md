# fsws

A simple Ruby-based file system web server for serving static files from a directory. Works on OSX, Windows, and Linux.

<div style="text-align:center" align="center">
  <img src="https://github.com/schmich/fsws/raw/master/assets/demo.gif" />
</div>

## Usage

Start a web server for files in the current directory:

```
$ gem install fsws
$ fsws
```

Specify a port:

```
$ fsws -p 777
```

Allow external connections:

```
$ fsws -h 0.0.0.0
```

## License

Copyright &copy; 2014 Chris Schmich
<br />
MIT License. See [LICENSE](LICENSE) for details.
