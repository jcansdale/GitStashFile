# GitStashFile

```
git stash-file foo.txt -m "pick me up later"
```

# Update

Use this instead!

```
git stash push -m "pick me up later" -- foo.txt
```

or

```
git stash -- foo.txt
```
