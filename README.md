# Vamboo

仮想マシンをお手軽にバックアップするためのツール、`virtual machine backup util`それが`vamboo`

## インストール

次のコマンドからアプリケーションをインストールできます

	$ gem instal vamboo

ソースコードからビルドする場合は

	$ rake build
	$ rake install


## 使い方

まず、設定ファイルの配置を行います。

	vamboo init

デフォルトで`/usr/local/etc/vamboo`に`Vamboofile`が生成されます。また環境変数`VAMBOO_HOME`を定義していれば、その直下に`Vamboofile`が生成されます。

`Vamboofile`にはバックアップ対象となる仮想マシンの情報を入力します。


```ruby
require "vamboo/domainlist" 

DomainList.define do 
	#add("仮想マシンのドメイン名", "仮想ハードディスクのパス")
	add("my_domay", "/path/to/domain/hd") 
end
```

`Vamboofile`に記述された仮想マシンを全てバックアップを行うには、次のコマンドから行います。

	vamboo full_backup [backup destination path]

## TODO

 - 特定の仮想マシンのバックアップ機能の実装
 - 仮想マシン定義のXMLから、仮想ハードディスクのパスを特定する