# checking dependencies
if ! command -v jq &> /dev/null
then
	echo "jq is required"
	exit
fi

TMPDIR=$(mktemp -d)
GENTARGET=$TMPDIR/result.side
TARGET=$GENTARGET


function usage(){
			echo "usage:"
		       	echo "     ./merge-side.sh -b base.side -t test.side [-o output.side]"	
}

while getopts "hb:t:o:" opt; do
	case ${opt} in
		b )
			BASE=$OPTARG
			;;
		t )
			TESTSRC=$OPTARG
			;;
		o )	
			TARGET=$OPTARG
			;;

		\? )
			# invalid option
			;;
		: )
			echo "Missing required parameter: $OPTARG"
			exit -1
			;;
		h ) 
			usage
			exit -1
			;;
	esac
done

if [ -z ${BASE} ] || [ -z ${TESTSRC} ]; then
	echo "missing required parameters"
	usage
	exit -1 
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
