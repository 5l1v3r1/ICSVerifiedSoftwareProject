#
# Copyright 2018, Data61
# Commonwealth Scientific and Industrial Research Organisation (CSIRO)
# ABN 41 687 119 230.
#
# This software may be distributed and modified according to the terms of
# the BSD 2-Clause license. Note that NO WARRANTY is provided.
# See "LICENSE_BSD2.txt" for details.
#
# @TAG(DATA61_BSD)
#

cmake_minimum_required(VERSION 3.8.2)

# /*? macros.generated_file_notice() ?*/

# Include the CapDL tools build helpers, we will need this later one when generating capDL targets
find_file(CAPDL_LOADER_BUILD_HELPERS helpers.cmake PATHS ${CMAKE_SOURCE_DIR}/projects/capdl/capdl-loader-app CMAKE_FIND_ROOT_PATH_BOTH)
mark_as_advanced(FORCE CAPDL_LOADER_BUILD_HELPERS)
if("${CAPDL_LOADER_BUILD_HELPERS}" STREQUAL "CAPDL_LOADER_BUILD_HELPERS-NOTFOUND")
    message(FATAL_ERROR "Failed to find helpers.cmake. Consider cmake -DCAPDL_LOADER_BUILD_HELPERS=/path/to/helpers.cmake")
endif()
include("${CAPDL_LOADER_BUILD_HELPERS}")

# Define names for tools we will use
set(OBJCOPY ${CROSS_COMPILER_PREFIX}objcopy)

# Declare our 'core' CAmkES libraries. These are the libraries that are considered minimal for the
# glue code that is linked to camkes applications to run
set(CAMKES_CORE_LIBS "sel4;muslc;sel4camkes;sel4sync;utils;sel4vka;sel4utils;sel4platsupport;platsupport;sel4vspace;sel4muslcsys")

# The main function generated by CAmkES does not conform to the standard main
# signatures, so disable warnings for this.
set(CAMKES_C_FLAGS "-Wno-main")

/*- set instances = composition.instances -*/
/*- set connections = composition.connections -*/

/*# The terms 'group' and 'address space' are currently synonymous. We can
 *# derive the groups by collecting all the instances' address spaces.
  #*/
/*- set groups = set(map(lambda('x: x.address_space'), filter(lambda('x: not x.type.hardware'), instances))) -*/

# We build up a list of all the generated items that we want to construct a single
# camkes invocation
set(item_list "")
set(outfile_list "")
set(reflow_commands "")
set(deps_list "")
set(elfs_list "")
set(camkes_ver_opts "")

macro(ParentListAppend list)
    set(local_list_value "${${list}}")
    list(APPEND local_list_value ${ARGN})
    set(${list} "${local_list_value}" PARENT_SCOPE)
endmacro(ParentListAppend list)

# Helper function for declaring a generated file
function(CAmkESGen output item)
    cmake_parse_arguments(PARSE_ARGV 2 CAMKES_GEN "SOURCE;C_STYLE;THY_STYLE" "SOURCES_VAR;VER_BASE_NAME" "DEPENDS;ELFS")
    if (NOT "${CAMKES_GEN_UNPARSED_ARGUMENTS}" STREQUAL "")
        message(FATAL_ERROR "Unknown arguments to CAmkESGen: ${CAMKES_GEN_UNPARSED_ARGUMENTS}")
    endif()
    # generate command
    get_filename_component(out_dir "${output}" DIRECTORY)
    # Reflow generated files if requested
    if (CAMKES_GEN_C_STYLE AND (NOT ("${CAMKES_C_FMT_INVOCATION}" STREQUAL "")))
        ParentListAppend(reflow_commands COMMAND sh -c
            "${CAMKES_C_FMT_INVOCATION} ${output} | ${CAMKES_SPONGE_INVOCATION} ${output}")
    elseif(CAMKES_GEN_THY_STYLE)
        ParentListAppend(reflow_commands COMMAND sh -c
            "${TPP_TOOL} ${output} | ${CAMKES_SPONGE_INVOCATION} ${output}")
    endif()
    # Append the item and outfile
    ParentListAppend(item_list "${item}")
    ParentListAppend(outfile_list "${output}")
    ParentListAppend(deps_list "${CAMKES_GEN_DEPENDS}")
    ParentListAppend(elfs_list "${CAMKES_GEN_ELFS}")
    ParentListAppend(deps_list "${CAMKES_GEN_ELFS}")
    # Pass along base name for verification templates
    if (NOT "${CAMKES_GEN_VER_BASE_NAME}" STREQUAL "")
        ParentListAppend(camkes_ver_opts "--verification-base-name=${CAMKES_GEN_VER_BASE_NAME}")
    endif()
    # Add to the sources list if it's a source file
    if (CAMKES_GEN_SOURCE)
        if (CAMKES_GEN_SOURCES_VAR)
            ParentListAppend("${CAMKES_GEN_SOURCES_VAR}" "${output}")
        else ()
            ParentListAppend(gen_sources "${output}")
        endif()
    endif()
    # Always add to the list of generated files
    ParentListAppend(gen_files "${output}")
endfunction(CAmkESGen)

# Generate all the files declared previously. object_state_op is either
# load- or save-object-state, depending on whether the object state has
# already been built.
function(CAmkESOutputGenCommand object_state_op)
    if ("${item_list}" STREQUAL "")
        return()
    endif()
    list(LENGTH outfile_list outfile_list_count)
    add_custom_command(
        OUTPUT ${outfile_list}
        COMMAND
            ${CMAKE_COMMAND} -E env ${CAMKES_TOOL_ENVIRONMENT} "${CAMKES_TOOL}"
                "--item;$<JOIN:${item_list},;--item;>"
                "--outfile;$<JOIN:${outfile_list},;--outfile;>"
                "--load-ast=${CMAKE_CURRENT_BINARY_DIR}/ast.pickle"
                "--${object_state_op}=${CMAKE_CURRENT_BINARY_DIR}/object.pickle"
                "$<$<BOOL:${elfs_list}>:--elf$<SEMICOLON>>$<JOIN:${elfs_list},$<SEMICOLON>--elf$<SEMICOLON>>"
                ${camkes_ver_opts}
                ${CAMKES_FLAGS}
        ${reflow_commands}
        DEPENDS
            ${CAMKES_ADL_SOURCE}
            /*? ' '.join(imported) ?*/
            # This pulls in miscellaneous dependencies 
            # which is used by the camkes tool
            ${CAMKES_TOOL_DEPENDENCIES}
            # Any additional dependencies from the files
            ${deps_list}
        VERBATIM
        COMMAND_EXPAND_LISTS
        COMMENT "Performing CAmkES generation for ${outfile_list_count} files"
    )
    set(reflow_commands "" PARENT_SCOPE)
    set(item_list "" PARENT_SCOPE)
    set(deps_list "" PARENT_SCOPE)
    set(outfile_list "" PARENT_SCOPE)
    set(elfs_list "" PARENT_SCOPE)
    set(camkes_ver_opts "" PARENT_SCOPE)
endfunction(CAmkESOutputGenCommand)

# helper for appending lists of generator expressions
function(AppendGenerator output new_list_value)
    # determine if there is anything in the original list OR the new list, and use that to deteremine
    # whether or not to put a semicolon between the two
    set(prop "${${output}}")
    set(new_list "${prop}$<$<OR:$<BOOL:${prop}>,$<BOOL:${new_list_value}>>:$<SEMICOLON>>${new_list_value}")
    set(${output} "${new_list}" PARENT_SCOPE)
endfunction(AppendGenerator)

# Helper for constructing a generator expression that evalutes to the provided value if it exists,
# or to a default value.
# if maybe_value is the empty string
#  evaluate to the contents of default
# else
#  evaluate to the contents of maybe_value
# Both 'default' and 'maybe_value' can themselves be generator expressions, allow for chaining usages of
# this together to build nested ORs.
function(GeneratorValueOrDefault output default maybe_value)
    set(new_output "$<IF:$<STREQUAL:${maybe_value},>,${default},${maybe_value}>")
    set(${output} "${new_output}" PARENT_SCOPE)
endfunction(GeneratorValueOrDefault)

# A target for each binary that we need to build
/*- for i in instances if not i.type.hardware -*/
    # Variable for collecting generated files
    set(gen_files "")
    set(gen_sources "")
    set(cakeml_sources "")
    # If no instance target exists declare it to simplify the logic of the generator expressions
    set (instance_target "CAmkESComponent_/*? i.type.name ?*/_instance_/*? i.name ?*/")
    if (NOT (TARGET ${instance_target}))
        add_custom_target(${instance_target})
    endif()
    # Retrieve the static sources for the component
    set(static_sources "$<TARGET_PROPERTY:CAmkESComponent_/*? i.type.name ?*/,COMPONENT_SOURCES>")
    AppendGenerator(static_sources "$<TARGET_PROPERTY:${instance_target},COMPONENT_SOURCES>")
    set(extra_c_flags "$<TARGET_PROPERTY:CAmkESComponent_/*? i.type.name ?*/,COMPONENT_C_FLAGS>")
    AppendGenerator(extra_c_flags "$<TARGET_PROPERTY:${instance_target},COMPONENT_C_FLAGS>")
    set(extra_ld_flags "$<TARGET_PROPERTY:CAmkESComponent_/*? i.type.name ?*/,COMPONENT_LD_FLAGS>")
    AppendGenerator(extra_ld_flags "$<TARGET_PROPERTY:${instance_target},COMPONENT_LD_FLAGS>")
    set(extra_libs "$<TARGET_PROPERTY:CAmkESComponent_/*? i.type.name ?*/,COMPONENT_LIBS>")
    AppendGenerator(extra_libs "$<TARGET_PROPERTY:${instance_target},COMPONENT_LIBS>")
    # Retrieve the static headers for the component. Ensure instance headers are placed first
    set(includes "$<TARGET_PROPERTY:${instance_target},COMPONENT_INCLUDES>")
    AppendGenerator(includes "$<TARGET_PROPERTY:CAmkESComponent_/*? i.type.name ?*/,COMPONENT_INCLUDES>")
    # Generate camkes header
    set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}//*? i.name ?*/")
    CAmkESGen("${generated_dir}/include/camkes.h" "/*? i.name ?*//header" C_STYLE)
    # Generated different entry points for the instance
    CAmkESGen("${generated_dir}/camkes.c" /*? i.name ?*//source SOURCE C_STYLE)
    /*- if configuration[i.name].get('debug') -*/
        CAmkESGen("${generated_dir}/camkes.debug.c" /*? i.name ?*//debug SOURCE C_STYLE)
    /*- endif -*/
    /*- if configuration[i.name].get('simple') -*/
        CAmkESGen("${generated_dir}/camkes.simple.c" /*? i.name ?*//simple SOURCE C_STYLE)
    /*- endif -*/
    /*- if configuration[i.name].get('rump_config') -*/
        CAmkESGen("${generated_dir}/camkes.rumprun.c" /*? i.name ?*//rumprun SOURCE C_STYLE)
    /*- endif -*/
    /*- if configuration[i.name].get('environment', 'c').lower() == 'c' -*/
        CAmkESGen("${generated_dir}/camkes.environment.c" /*? i.name ?*//c_environment_source SOURCE C_STYLE)
    /*- elif configuration[i.name].get('environment').lower() == 'cakeml' -*/
        set(cakeml_sources "$<TARGET_PROPERTY:CAmkESComponent_/*? i.type.name ?*/,COMPONENT_CAKEML_SOURCES>")
        CAmkESGen("${generated_dir}/camkesStartScript.sml" /*? i.name ?*//cakeml_start_source SOURCE SOURCES_VAR cakeml_sources)
        CAmkESGen("${generated_dir}/camkesEndScript.sml" /*? i.name ?*//cakeml_end_source SOURCE SOURCES_VAR cakeml_sources)
    /*- else -*/
        /*? raise(TemplateError('Unknown environment')) ?*/
    /*- endif -*/
    # Generate connectors for this instance
    /*- for c in connections -*/
        /*- for id, e in enumerate(c.from_ends) -*/
            set(unique_name /*? e.interface.name ?*/_/*? c.type.name ?*/_/*? id ?*/)
            /*- if e.instance.name == i.name -*/
                CAmkESGen("${generated_dir}/${unique_name}.c" /*? c.name ?*//from/source//*? id ?*/ SOURCE C_STYLE)
                # Add a rule to generate the header if this connector has a header template
                /*- if lookup_template('%s/from/header' % c.name, c) is not none -*/
                    CAmkESGen("${generated_dir}/include/${unique_name}.h" /*? c.name ?*//from/header//*? id ?*/ C_STYLE)
                /*- endif -*/
            /*- endif -*/
        /*- endfor -*/
        /*- for id, e in enumerate(c.to_ends) -*/
            set(unique_name /*? e.interface.name ?*/_/*? c.type.name ?*/_/*? id ?*/)
            /*- if e.instance.name == i.name -*/
                /*- if configuration[i.name].get('environment', 'c').lower() == 'cakeml' and lookup_template('%s/to/cakeml' % c.name,c) is not none -*/
                    CAmkESGen("${generated_dir}/connectorScript.sml" /*? c.name ?*//to/cakeml//*? id ?*/ SOURCE SOURCES_VAR cakeml_sources)
                /*- else -*/
                    CAmkESGen("${generated_dir}/${unique_name}.c" /*? c.name ?*//to/source//*? id ?*/ SOURCE C_STYLE)
                /*- endif -*/
                # Add a rule to generate the header if this connector has a header template
                /*- if lookup_template('%s/to/header' % c.name, c) is not none -*/
                    CAmkESGen("${generated_dir}/include/${unique_name}.h" /*? c.name ?*//to/header//*? id ?*/ C_STYLE)
                /*- endif -*/
            /*- endif -*/
        /*- endfor -*/
    /*- endfor -*/
    # Generate our linker script
    set(linker_file "${generated_dir}/linker.lds")
    CAmkESGen("${linker_file}" /*? i.name ?*//linker)
    # Create a target for all our generated files
    set(gen_target /*? i.name ?*/_generated)
    add_custom_target(${gen_target} DEPENDS ${gen_files})
    # Build the actual binary
    set(target /*? i.name ?*/.instance.bin)
    add_executable(${target} EXCLUDE_FROM_ALL
        ${static_sources}
        ${gen_sources}

    )
    # If COMPONENT_LINKER_LANGUAGE is set on the component target, set the LINKER_LANGUAGE of the executable
    get_property(link_language TARGET CAmkESComponent_/*? i.type.name ?*/ PROPERTY COMPONENT_LINKER_LANGUAGE)
    if (NOT "${link_language}" STREQUAL "")
        set_property(TARGET ${target} PROPERTY LINKER_LANGUAGE ${link_language})
    endif()
    # Build any CakeML library
    if (NOT ("${cakeml_sources}" STREQUAL ""))
        # Pull heap/stack size from component expression OR instances expression OR default to an arbitrary 50
        # The order here is important as we want the instance property to be able to override the component property
        GeneratorValueOrDefault(heap 50 $<TARGET_PROPERTY:CAmkESComponent_/*? i.type.name ?*/,COMPONENT_CAKEML_HEAP_SIZE>)
        GeneratorValueOrDefault(heap "${heap}" $<TARGET_PROPERTY:${instance_target},COMPONENT_CAKEML_HEAP_SIZE>)
        GeneratorValueOrDefault(stack 50 $<TARGET_PROPERTY:CAmkESComponent_/*? i.type.name ?*/,COMPONENT_CAKEML_STACK_SIZE>)
        GeneratorValueOrDefault(stack "${stack}" $<TARGET_PROPERTY:${instance_target},COMPONENT_CAKEML_STACK_SIZE>)
        # Additional directories for the HOL build to depend on
        get_property(cakeml_includes TARGET CAmkESComponent_/*? i.type.name ?*/ PROPERTY COMPONENT_CAKEML_INCLUDES)
        get_property(cakeml_depends TARGET CAmkESComponent_/*? i.type.name ?*/ PROPERTY COMPONENT_CAKEML_DEPENDS)
        DeclareCakeMLLib(camkescakeml_contents
            SOURCES "${cakeml_sources}"
            TRANSLATION_THEORY "camkesEnd"
            HEAP_SIZE "${heap}"
            STACK_SIZE "${stack}"
            RUNTIME_ENTRY "component_control_main"
            CAKEML_ENTRY "camkes_entry"
            INCLUDES ${cakeml_includes}
            DEPENDS "${gen_target}" "${cakeml_depends}"
        )
        target_link_libraries(${target} camkescakeml camkescakeml_contents)
    endif()
    target_include_directories(${target} PRIVATE ${includes} "${generated_dir}/include")
    # Depend upon core camkes libraries
    target_link_libraries(${target} ${CAMKES_CORE_LIBS})
    # Depend upon additional libraries
    target_link_libraries(${target} ${extra_libs})
    # Depend upon target that creates the generated source files
    add_dependencies(${target} ${gen_target} CAmkESComponent_/*? i.type.name ?*/)
    # Set our CAmkES specific additional link flags
    set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS
        " -static -nostdlib -u _camkes_start -e _camkes_start ")
    # Add extra flags specified by the user
    target_compile_options(${target} PRIVATE ${extra_c_flags} ${CAMKES_C_FLAGS})
    set_property(TARGET ${TARGET} APPEND_STRING PROPERTY LINK_FLAGS ${extra_ld_flags})
    # Only incrementally link if this instance is going on to become part of a
    # group.
    # TODO: we care about being grouped elsewhere as well. generalize this
    /*- set grouped = [False] -*/
    /*- for inst in instances if not i.type.hardware -*/
        /*- if id(i) != id(inst) and inst.address_space == i.address_space -*/
            /*- do grouped.__setitem__(0, True) -*/
        /*- endif -*/
    /*- endfor -*/
    /*- if grouped[0] -*/
        set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS " -Wl,--relocatable ")
    /*- endif -*/
    set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS " -Wl,--script=${linker_file} ")
/*- endfor -*/

# We need to apply objcopy to each component instance's ELF before we link them
# into a flattened binary in order to avoid symbol collision. Note that when we
# mangle symbols, we use the prefix 'camkes ' to avoid colliding with any
# user-provided symbols.
/*- set instancelist = set() -*/
/*- for i in instances if not i.type.hardware -*/
/*- set pre = NameMangling.Perspective(phase=NameMangling.TEMPLATES, instance=i.name, group=i.address_space) -*/
/*- set post = NameMangling.Perspective(phase=NameMangling.FILTERS, instance=i.name, group=i.address_space) -*/
    set(input_target /*? i.name ?*/.instance.bin)
    set(output ${CMAKE_CURRENT_BINARY_DIR}//*? i.name ?*/.instance-copy.bin)
    set(output_target /*? i.name ?*/_instance_copy_target)
    set(input $<TARGET_FILE:${input_target}>)
    add_custom_command(
        OUTPUT "${output}"
        COMMAND
        # Brace yourself. This is going to be a bumpy ride.
        ${OBJCOPY}
            /*# Use a dummy impossible symbol of the empty string here, because
             *# marking one symbol as 'keep global' causes all others to be demoted
             *# to local. This allows us to avoid symbol collisions from
             *# user-provided symbols.
              #*/
            --keep-global-symbol ""

            /*# Rename the entry point to avoid symbol conflicts when we are
             *# colocated with other components. Note that we will still use this as
             *# the entry point.
              #*/
            --redefine-sym "_camkes_start=/*? post['entry_symbol'] ?*/"

            /*- for c in connections -*/
                /*- if c.type.name == 'seL4DirectCall' -*/
                    /*# For all 'from' connection ends (calls to unresolved symbols),
                     *# rename the symbols so they will correctly link to the
                     *# implementations provided by the 'to' side.
                      #*/
                    /*- for e in c.from_ends -*/
                        /*- if id(e.instance) == id(i) -*/
                            /*- for m in e.interface.type.methods -*/
                                --redefine-sym "/*? e.interface.name ?*/_/*? m.name ?*/=camkes connection /*? e.parent.name ?*/_/*? m.name ?*/"
                            /*- endfor -*/
                        /*- endif -*/
                    /*- endfor -*/
                    /*# For all 'to' connection ends (implementations of procedures),
                     *# rename the symbols so they will be found during the next
                     *# linking stage. Note we need to mark them as 'keep global' or
                     *# they will not be visible during the next link.
                      #*/
                    /*- for e in c.to_ends -*/
                        /*- if id(e.instance) == id(i) -*/
                            /*- if '%s_%s' % (i.name, e.interface.name) in instancelist -*/
                                /*- continue -*/
                            /*- endif -*/
                            /*- do instancelist.add('%s_%s' % (i.name, e.interface.name)) -*/
                            /*- for m in e.interface.type.methods -*/
                                --redefine-sym "/*? e.interface.name ?*/_/*? m.name ?*/=camkes connection /*? e.parent.name ?*/_/*? m.name ?*/"
                                --keep-global-symbol "camkes connection /*? e.parent.name ?*/_/*? m.name ?*/"
                            /*- endfor -*/
                        /*- endif -*/
                    /*- endfor -*/
                /*- endif -*/
            /*- endfor -*/
            "${input}" "${output}"
        COMMAND
            # Some toolchains insert exception handling infrastructure whether we ask
            # for it or not. The preceding `objcopy` step breaks references in
            # implicit `.eh_frame`s and friends, which then goes on to cause a linker
            # warning. Rather than attempt some complicated gymnastics to repair these
            # references, we just strip the exception handling pieces. To further
            # complicate the process, some architectures require an `.eh_frame` and
            # attempting to remove it causes errors. To handle this we just blindly
            # try to remove it and mask errors. We can't do this unconditionally in
            # the preceding `objcopy` because it fails when our toolchain has *not*
            # inserted exception handling pieces or when we're targeting an
            # architecture that requires `.eh_frame`.
            bash -c "${OBJCOPY} --remove-section .eh_frame --remove-section .eh_frame_hdr \
                --remove-section .rel.eh_frame --remove-section .rela.eh_frame ${output} \
                >/dev/null 2>/dev/null"
        VERBATIM
        DEPENDS ${input_target}
    )
    add_custom_target(/*? i.name ?*/_instance_copy_target DEPENDS "${output}")
    # TODO target for dependencies
/*- endfor -*/

# Define the linker we used for instances groups. This is just C linking but without crt objects
# or any other libraries, we just want the flags to generate the correct binary type
set(CMAKE_INSTANCE_GROUP_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET>" CACHE INTERNAL "" FORCE)
# Finally link together the instances in the different groups */
/*- for g in groups -*/
    /*- set p = Perspective(group=g) -*/
    # Find all the instances that are part of this group */
    set(instances "")
    set(instance_targets "")
    /*- for i in instances if not i.type.hardware -*/
        /*- set q = Perspective(group=i.address_space) -*/
        /*- if p['elf_name'] == q['elf_name'] -*/
            list(APPEND instances "/*? i.name ?*/.instance-copy.bin")
            list(APPEND instance_targets "/*? i.name ?*/_instance_copy_target")
            # Define the copies as objects in case we need to link them into a group and
            # we would like cmake to not attempt to compile them
            set_property(SOURCE "/*? i.name ?*/.instance-copy.bin" PROPERTY EXTERNAL_OBJECT TRUE)
        /*- endif -*/
    /*- endfor -*/
    set(target ${CMAKE_CURRENT_BINARY_DIR}//*? p['elf_name'] ?*/)
    list(LENGTH instances instances_len)
    if (${instances_len} GREATER 1)
        add_executable(/*? p['elf_name'] ?*/ EXCLUDE_FROM_ALL ${instances})
        add_dependencies(/*? p['elf_name'] ?*/ ${instance_targets})
        # Use a custom linker definition that will not include crt objects
        set_property(TARGET /*? p['elf_name'] ?*/ PROPERTY LINKER_LANGUAGE INSTANCE_GROUP)
        # Note that we deliberately give groups a
        # broken entry point so that, if they are incorrectly loaded without correct
        # initial instruction pointers, threads will immediately fault
        set_property(TARGET /*? p['elf_name'] ?*/ APPEND PROPERTY LINK_FLAGS " -static -nostdlib --entry=0x0 -Wl,--build-id=none")
    else()
        add_custom_command(
            OUTPUT ${target}
            COMMAND
                cp "${instances}" "${target}"
            DEPENDS
                ${instances}
                ${instance_targets}
        )
    endif()
    add_custom_target(/*? p['elf_name'] ?*/_group_target DEPENDS "${target}")
/*- endfor -*/

# Generate our targets up to this point
CAmkESOutputGenCommand(save-object-state)

set(capdl_elf_depends "")
set(capdl_elf_targets "")
/*- for g in groups -*/
    /*- set p = Perspective(group=g) -*/
    list(APPEND capdl_elfs "${CMAKE_CURRENT_BINARY_DIR}//*? p['elf_name'] ?*/")
    list(APPEND capdl_elf_targets "/*? p['elf_name'] ?*/_group_target")
/*- endfor -*/
# CapDL generation. Aside from depending upon the CAmkES specifications themselves, it
# depends upon the copied instance binaries
# First define the capDL spec generation from CAmkES
CAmkESGen("${CAMKES_CDL_TARGET}" capdl DEPENDS "${capdl_elf_targets}" ELFS "${capdl_elfs}")
CAmkESOutputGenCommand(load-object-state)
add_custom_target(camkes_capdl_target DEPENDS "${CAMKES_CDL_TARGET}")

# Invoke the parse-capDL tool to turn the CDL spec into a C spec
CapDLToolCFileGen(capdl_c_spec_target capdl_spec.c "${CAMKES_CDL_TARGET}" "${CAPDL_TOOL_BINARY}"
    MAX_IRQS ${CapDLLoaderMaxIRQs}
    DEPENDS camkes_capdl_target install_capdl_tool "${CAPDL_TOOL_BINARY}")

# Ask the CapDL tool to generate an image with our given copied/mangled instances
BuildCapDLApplication(
    C_SPEC "capdl_spec.c"
    /*- for g in groups -*/
        /*- set p = Perspective(group=g) -*/
        ELF "${CMAKE_CURRENT_BINARY_DIR}//*? p['elf_name'] ?*/"
    /*- endfor -*/
    DEPENDS
        # Dependency on the C_SPEC and ELFs are added automatically, we just have to add the target
        # dependencies
        capdl_c_spec_target
        ${capdl_elf_targets}
    OUTPUT "capdl-loader"
)
DeclareRootserver("capdl-loader")

# Generate Isabelle theory scripts if needed
if (${CAmkESCapDLVerification})
    # Base name for Isabelle theories. We derive this from the app name,
    # but mangled to ensure that it is a valid identifier.
    string(MAKE_C_IDENTIFIER ${CAMKES_APP} VER_BASE_NAME)

    # Generated theory names. These must be consistent with the templates.
    set(CAMKES_CDL_THY "${VER_BASE_NAME}_CDL.thy")
    set(CAMKES_ADL_THY "${VER_BASE_NAME}_Arch_Spec.thy")
    set(CAMKES_CDL_REFINE_THY "${VER_BASE_NAME}_CDL_Refine.thy")
    set(CAMKES_VER_ROOT "ROOT")

    # ROOT file
    CAmkESGen("${CAMKES_VER_ROOT}" "isabelle-root" THY_STYLE VER_BASE_NAME ${VER_BASE_NAME})
    add_custom_target(isabelle_root DEPENDS "${CAMKES_VER_ROOT}")

    # Generate these theory files as part of overall build
    # FIXME: hack?
    add_dependencies("capdl-loader" isabelle_root)

    # Isabelle capDL spec
    add_custom_command(
        OUTPUT "${CAMKES_CDL_THY}"
        COMMAND
            # HACK: workaround for SELFOUR-6
            # This removes Grant from all endpoint caps
            ${CAPDL_THY_HACK_TOOL} <"${CAMKES_CDL_TARGET}" >"${CAMKES_CDL_TARGET}.munge"
        COMMAND
            ${CAPDL_TOOL_BINARY} --isabelle "${CAMKES_CDL_THY}" "${CAMKES_CDL_TARGET}.munge"
        DEPENDS
            "${CAMKES_CDL_TARGET}"
            camkes_capdl_target
            "${CAPDL_TOOL_BINARY}"
            install_capdl_tool
        BYPRODUCTS
            "${CAMKES_CDL_TARGET}.munge"
    )
    add_custom_target(camkes_cdl_thy DEPENDS "${CAMKES_CDL_THY}")
    add_dependencies(isabelle_root camkes_cdl_thy)

    # ADL spec
    CAmkESGen("${CAMKES_ADL_THY}" "arch-spec" THY_STYLE VER_BASE_NAME ${VER_BASE_NAME})
    add_custom_target(camkes_adl_thy DEPENDS "${CAMKES_ADL_THY}")
    add_dependencies(isabelle_root camkes_adl_thy)

    # CDL refinement proof
    CAmkESGen("${CAMKES_CDL_REFINE_THY}" "cdl-refine" THY_STYLE VER_BASE_NAME ${VER_BASE_NAME}
              DEPENDS "${capdl_elf_targets}" ELFS "${capdl_elfs}")
    add_custom_target(camkes_cdl_refine_thy DEPENDS "${CAMKES_CDL_REFINE_THY}")
    add_dependencies(isabelle_root camkes_cdl_refine_thy)

    CAmkESOutputGenCommand(load-object-state)
endif()

# Ensure we generated all the files we intended to, this is just sanity checking
if (NOT ("${item_list}" STREQUAL ""))
    message(FATAL_ERROR "Items added through CAmkESGen not generated")
endif()
