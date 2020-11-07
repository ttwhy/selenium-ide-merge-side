TMPDIR=$(mktemp -d)

# checking dependencies
if ! command -v jq &> /dev/null
then
	echo "jq is required"
	exit
fi

GENTARGET=$TMPDIR/result.side
TARGET=$GENTARGET
while getopts "hb:t:o:" opt; do
	case ${opt} in
		b )
			BASE=$OPTARG
			echo $BASE
			;;
		t )
			TESTSRC=$OPTARG
			echo $TESTSRC
			;;
		o )	
			TARGET=$OPTARG
			echo $TARGET
			;;

		h ) 
			echo "usage:"
		       	echo "./merge-side.sh -b base.side -t test.side [-o output.side]"	
			exit 0
			;;
		\? )
			echo "invalid option -$OPTARG" 1>&2
			exit 1
			;;
	esac
done

if [ -z ${BASE} ] || [ -z ${TESTSRC} ]; then
	echo "missing required parameters"
fi


# extract functions
cat $BASE | jq '. | {tests: .tests | map(. | select(.name | contains("~")) | {id: .id, name: .name, commands: .commands} ) }' > $TMPDIR/functions.json

# extract tests
cat $TESTSRC | jq '. | {tests: .tests | map(. | select(.name | contains("~") | not) | {id: .id, name: .name, commands: .commands} ) }' > $TMPDIR/tests.json

# extract suite
cat $TESTSRC | jq '. | {id: .id, version: .version, name: .name, url: .url, suites: .suites}' > $TMPDIR/suites.json

# merge stuff togther again
jq -s '.[0].tests + .[1].tests | {tests: .}' $TMPDIR/tests.json $TMPDIR/functions.json > $TMPDIR/functionality.json

jq -s add $TMPDIR/suites.json $TMPDIR/functionality.json > $TARGET 

if [ "${GENTARGET}" == "${TARGET}" ]; then
	cat $TARGET
fi
exit $?
