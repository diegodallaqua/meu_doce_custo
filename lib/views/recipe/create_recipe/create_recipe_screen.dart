import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:meu_doce_custo/core/ui/dialogs/dialog_recipe_category.dart';
import 'package:meu_doce_custo/stores/create/create_ingredient_used_store.dart';
import '../../../core/ui/custom_field.dart';
import '../../../models/ingredient_used.dart';
import '../../../models/recipe.dart';
import 'package:mobx/mobx.dart';

import '../../../core/global/custom_colors.dart';
import '../../../core/ui/body_container.dart';
import '../../../core/ui/custom_app_bar.dart';
import '../../../core/ui/custom_form_field.dart';
import '../../../core/ui/patterned_buttom.dart';
import '../../../core/ui/title_text_form.dart';
import '../../../stores/create/create_recipe_store.dart';
import '../../../stores/list/recipe_store.dart';
import '../recipe/recipe_screen.dart';
import 'components/ingredient_used_container.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key, this.recipe}) : super(key: key);

  final Recipe? recipe;

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  late bool editing;
  late final CreateRecipeStore createRecipeStore;
  late final CreateIngredientUsedStore createIngredientUsedStore;
  final recipeStore = GetIt.I<RecipeStore>();
  late ReactionDisposer reactionDisposer;

  @override
  void initState() {
    super.initState();
    editing = widget.recipe != null;
    createRecipeStore = CreateRecipeStore(widget.recipe);

    //QUANDO SALVAR COM SUCESSO, VOLTA PARA A TELA ANTERIOR E RECARREGA OS DADOS
    when((_) => createRecipeStore.savedOrUpdatedOrDeleted, () {
      recipeStore.refreshData();
      backToPreviousScreen();
    });

    reactionDisposer = reaction((_) => createRecipeStore.error, (error) {
      if (error != null) {
        print(error);
      }
    });
  }

  //Ao sair do widget
  @override
  void dispose() {
    reactionDisposer();
    super.dispose();
  }

  void backToPreviousScreen() {
    Navigator.of(context).pop(
      MaterialPageRoute(
        builder: (context) => RecipeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(
        title: editing ? 'Editar Receita' : 'Cadastrar Receita',
        onBackButtonPressed: backToPreviousScreen,
      ),
      body: BodyContainer(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: const ScrollBehavior(),
                      child: GlowingOverscrollIndicator(
                        axisDirection: AxisDirection.down,
                        color: CustomColors.gay_pink,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 15),
                              TitleTextForm(title: 'Nome da Receita'),
                              Observer(
                                builder: (context) =>
                                    CustomFormField(
                                      initialvalue: createRecipeStore.name,
                                      onChanged: createRecipeStore.setName,
                                      error: createRecipeStore.nameError,
                                      secret: false,
                                    ),
                              ),
                              TitleTextForm(title: 'Categoria da Receita'),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 12),
                                child: Observer(
                                  builder: (context) =>
                                      CustomField(
                                        onTap: () async {
                                          final result = await showDialog(
                                            context: context,
                                            builder: (context) => DialogRecipeCategory(selectedRecipeCategory: createRecipeStore.recipeCategory),
                                          );
                                          if (result != null) {
                                            createRecipeStore.setRecipeCategory(
                                                result);
                                          }
                                        },
                                        title: createRecipeStore.recipeCategory
                                            ?.name ?? "Selecione a Categoria",
                                        borderColor: createRecipeStore
                                            .recipeCategoryError != null
                                            ? Colors.red.shade700
                                            : CustomColors.mint.withAlpha(50),
                                        error: createRecipeStore
                                            .recipeCategoryError,
                                        clearOnPressed: null,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Observer(
                                builder: (_) {
                                  final future = createRecipeStore.ingredientsFuture;

                                  // Enquanto ainda não existe future (primeiro build)
                                  if (future == null) {
                                    return const Center(
                                      child: CircularProgressIndicator(color: CustomColors.mint),
                                    );
                                  }

                                  return FutureBuilder<List<IngredientUsed>>(
                                    future: future,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(color: CustomColors.mint),
                                        );
                                      }

                                      final ingredients = snapshot.data ?? const <IngredientUsed>[];

                                      return IngredientUsedContainer(
                                        initialIngredients: ingredients,
                                        onIngredientsChanged: createRecipeStore.updateIngredients,
                                      );
                                    },
                                  );
                                },
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: editing
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: PatternedButton(
                            color: CustomColors.sweet_cream,
                            textColor: CustomColors.lipstick_pink,
                            text: 'Excluir',
                            largura: screenSize.width * 0.3,
                            function: editing
                                ? () async {
                              await createRecipeStore.deleteRecipe();
                            }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: Observer(
                            builder: (context) =>
                                GestureDetector(
                                  onTap: () =>
                                      createRecipeStore.invalidSendPressed(),
                                  child: PatternedButton(
                                    color: CustomColors.gay_pink,
                                    text: 'Salvar',
                                    largura: screenSize.width * 0.65,
                                    function: createRecipeStore.isFormValid
                                        ? () async {
                                      if (editing) {
                                        await createRecipeStore.editPressed();
                                      } else {
                                        await createRecipeStore.createPressed();
                                      }
                                    }
                                        : null,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ) : Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Observer(
                            builder: (context) =>
                                GestureDetector(
                                  onTap: () =>
                                      createRecipeStore.invalidSendPressed(),
                                  child: PatternedButton(
                                    color: CustomColors.gay_pink,
                                    text: 'Salvar',
                                    largura: screenSize.width * 0.95,
                                    function: createRecipeStore.isFormValid
                                        ? () async {
                                      if (editing) {
                                        await createRecipeStore.editPressed();
                                      } else {
                                        await createRecipeStore.createPressed();
                                      }
                                    } : null,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}