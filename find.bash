find . -name "*.ks" | xargs -i{} grep "$1" {} -Hn
