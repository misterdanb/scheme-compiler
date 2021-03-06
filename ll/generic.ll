define i64 @prim_generic_eq(i64 %a, i64 %b) {
	%test = icmp eq i64 %a, %b
	br i1 %test, label %equal, label %not_equal
equal:
	%res_equal = load i64, i64* @prim_bool_true
	ret i64 %res_equal
not_equal:
	%res_not_equal = load i64, i64* @prim_bool_false
	ret i64 %res_not_equal
}

; TODO: closure
define i64 @prim_generic_equal(i64 %a, i64 %b) {
test_fixnum:
	%fixnum_tag = load i64, i64* @prim_fixnum_tag
	%fixnum_mask = load i64, i64* @prim_fixnum_mask
	%a_fixnum_tag = and i64 %a, %fixnum_mask
	%fixnum_test = icmp eq i64 %a_fixnum_tag, %fixnum_tag
	br i1 %fixnum_test, label %check_fixnum_equality, label %test_char
check_fixnum_equality:
	%fixnum_equal = call i64 @prim_fixnum_equal(i64 %a, i64 %b)
	ret i64 %fixnum_equal

test_char:
	%char_tag = load i64, i64* @prim_char_tag
	%char_mask = load i64, i64* @prim_char_mask
	%a_char_tag = and i64 %a, %char_mask
	%char_test = icmp eq i64 %a_char_tag, %char_tag
	br i1 %char_test, label %check_char_equality, label %test_bool
check_char_equality:
	%char_equal = call i64 @prim_char_equal(i64 %a, i64 %b)
	ret i64 %char_equal

test_bool:
	%bool_tag = load i64, i64* @prim_bool_tag
	%bool_mask = load i64, i64* @prim_bool_mask
	%a_bool_tag = and i64 %a, %bool_mask
	%bool_test = icmp eq i64 %a_bool_tag, %bool_tag
	br i1 %bool_test, label %check_bool_equality, label %test_empty_list
check_bool_equality:
	%bool_equal = call i64 @prim_bool_equal(i64 %a, i64 %b)
	ret i64 %bool_equal

test_empty_list:
	%empty_list = load i64, i64* @prim_pair_empty_list
	%empty_list_test = icmp eq i64 %a, %empty_list
	br i1 %empty_list_test, label %check_empty_list_equality, label %test_pair
check_empty_list_equality:
	; fixnum equality works just fine here
	%empty_list_equal = call i64 @prim_fixnum_equal(i64 %a, i64 %b)
	ret i64 %empty_list_equal

test_pair:
	%pair_tag = load i64, i64* @prim_pair_tag
	%pair_mask = load i64, i64* @prim_heap_mask
	%a_pair_tag = and i64 %a, %pair_mask
	%pair_test = icmp eq i64 %a_pair_tag, %pair_tag
	br i1 %pair_test, label %check_pair_equality, label %test_string
check_pair_equality:
	%pair_equal = call i64 @prim_pair_equal(i64 %a, i64 %b)
	ret i64 %pair_equal

test_string:
	%string_tag = load i64, i64* @prim_string_tag
	%string_mask = load i64, i64* @prim_heap_mask
	%a_string_tag = and i64 %a, %string_mask
	%string_test = icmp eq i64 %a_string_tag, %string_tag
	br i1 %string_test, label %check_string_equality, label %test_symbol
check_string_equality:
	%string_equal = call i64 @prim_string_equal(i64 %a, i64 %b)
	ret i64 %string_equal

test_symbol:
	%symbol_tag = load i64, i64* @prim_symbol_tag
	%symbol_mask = load i64, i64* @prim_heap_mask
	%a_symbol_tag = and i64 %a, %symbol_mask
	%symbol_test = icmp eq i64 %a_symbol_tag, %symbol_tag
	br i1 %symbol_test, label %check_symbol_equality, label %error
check_symbol_equality:
	%symbol_equal = call i64 @prim_symbol_equal(i64 %a, i64 %b)
	ret i64 %symbol_equal

error:
	%res_false = load i64, i64* @prim_bool_false
	ret i64 %res_false
}
