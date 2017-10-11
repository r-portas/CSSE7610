for i in $(seq 1 100); do
	java -cp bin Main > /dev/null
    echo Running $i
done
