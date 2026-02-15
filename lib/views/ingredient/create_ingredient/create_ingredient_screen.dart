import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:meu_doce_custo/models/ingredient.dart';
import 'package:mobx/mobx.dart';

import '../../../core/global/custom_colors.dart';
import '../../../core/ui/body_container.dart';
import '../../../core/ui/custom_app_bar.dart';
import '../../../core/ui/custom_field.dart';
import '../../../core/ui/custom_form_field.dart';
import '../../../core/ui/dialogs/dialog_brand.dart';
import '../../../core/ui/patterned_buttom.dart';
import '../../../core/ui/title_text_form.dart';
import '../../../stores/create/create_ingredient_store.dart';
import '../../../stores/list/ingredient_store.dart';
import '../ingredient/ingredient_screen.dart';

class CreateIngredientScreen extends StatefulWidget {
  const CreateIngredientScreen({Key? key, this.ingredient}) : super(key: key);

  final Ingredient? ingredient;

  @override
  State<CreateIngredientScreen> createState() => _CreateIngredientScreenState();
}

class _CreateIngredientScreenState extends State<CreateIngredientScreen> {
  late bool editing;
  late final CreateIngredientStore createIngredientStore;
  final ingredientStore = GetIt.I<IngredientStore>();
  late ReactionDisposer reactionDisposer;

  @override
  void initState() {
    super.initState();
    editing = widget.ingredient != null;
    createIngredientStore = CreateIngredientStore(widget.ingredient);

    // QUANDO SALVAR COM SUCESSO, VOLTA PARA A TELA ANTERIOR E RECARREGA OS DADOS
    when((_) => createIngredientStore.savedOrUpdatedOrDeleted, () {
      ingredientStore.refreshData();
      backToPreviousScreen();
    });

    reactionDisposer = reaction((_) => createIngredientStore.error, (error) {
      if (error != null) {
        print(error);
      }
    });
  }

  // Ao sair do widget
  @override
  void dispose() {
    reactionDisposer();
    super.dispose();
  }

  void backToPreviousScreen() {
    Navigator.of(context).pop(
      MaterialPageRoute(
        builder: (context) => IngredientScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(
        title: editing ? 'Editar Ingrediente' : 'Cadastrar Ingrediente',
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
                              TitleTextForm(title: 'Nome do Ingrediente'),
                              Observer(
                                builder: (context) => CustomFormField(
                                  initialvalue: createIngredientStore.name,
                                  onChanged: createIngredientStore.setName,
                                  error: createIngredientStore.nameError,
                                  secret: false,
                                ),
                              ),
                              TitleTextForm(title: 'Preço'),
                              Observer(
                                builder: (context) => CustomFormField(
                                  typeKeyboard: TextInputType.number,
                                  input: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CentavosInputFormatter(),
                                  ],
                                  initialvalue: createIngredientStore.price,
                                  onChanged: createIngredientStore.setPrice,
                                  textInputAction: TextInputAction.next,
                                  error: createIngredientStore.priceError,
                                ),
                              ),

                              TitleTextForm(title: 'Tamanho'),
                              Observer(
                                builder: (context) => Row(
                                  children: [
                                    Expanded(
                                      child: CustomFormField(
                                        initialvalue: createIngredientStore.size,
                                        onChanged: createIngredientStore.setSize,
                                        error: createIngredientStore.sizeError,
                                        secret: false,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ToggleButtons(
                                      borderRadius: BorderRadius.circular(12),
                                      isSelected: [
                                        createIngredientStore.is_ml == true,
                                        createIngredientStore.is_ml == false
                                      ],
                                      onPressed: (int index) {
                                        createIngredientStore.toggleIsMl();
                                      },
                                      color: CustomColors.just_regular_brown,
                                      selectedColor: CustomColors.sweet_cream,
                                      fillColor: CustomColors.mint,
                                      constraints: const BoxConstraints(
                                        minHeight: 40.0,
                                        minWidth: 50.0,
                                      ),
                                      children: const [
                                        Text('ml'),
                                        Text('g'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),

                              TitleTextForm(title: 'Marca do Ingrediente'),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                                child: Observer(
                                  builder: (context) => CustomField(
                                    onTap: () async {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (context) => DialogBrand(
                                            selectedBrand: createIngredientStore.brand
                                        ),
                                      );
                                      if (result != null) {
                                        createIngredientStore.setBrand(result);
                                      }
                                    },
                                    title: createIngredientStore.brand?.name ?? "Selecione a Marca",
                                    borderColor: createIngredientStore.brandError != null ? Colors.red.shade700 : CustomColors.mint.withAlpha(50),
                                    error: createIngredientStore.brandError,
                                    clearOnPressed: null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: editing ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: PatternedButton(
                            color: CustomColors.sweet_cream,
                            textColor: CustomColors.lipstick_pink,
                            text: 'Excluir',
                            largura: screenSize.width * 0.3,
                            function: editing ? () async {
                              await createIngredientStore.deleteIngredient();
                            } : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: Observer(
                            builder: (context) => GestureDetector(
                              onTap: () => createIngredientStore.invalidSendPressed(),
                              child: PatternedButton(
                                color: CustomColors.gay_pink,
                                text: 'Salvar',
                                largura: screenSize.width * 0.65,
                                function: createIngredientStore.isFormValid ? () async {
                                  if (editing) {
                                    await createIngredientStore.editPressed();
                                  } else {
                                    await createIngredientStore.createPressed();
                                  }
                                } : null,
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
                            builder: (context) => GestureDetector(
                              onTap: () => createIngredientStore.invalidSendPressed(),
                              child: PatternedButton(
                                color: CustomColors.gay_pink,
                                text: 'Salvar',
                                largura: screenSize.width * 0.95,
                                function: createIngredientStore.isFormValid ? () async {
                                  if (editing) {
                                    await createIngredientStore.editPressed();
                                  } else {
                                    await createIngredientStore.createPressed();
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
