import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Owner } from './owner.entity';
import { Cattle } from '../cattle/cattle.entity';
import { Expense } from '../expenses/expense.entity';
import { Sale } from '../sales/sale.entity';
import { CreateOwnerDto } from './dto/create-owner.dto';
import { UpdateOwnerDto } from './dto/update-owner.dto';

@Injectable()
export class OwnersService {
  constructor(
    @InjectRepository(Owner) private ownerRepo: Repository<Owner>,
    @InjectRepository(Cattle) private cattleRepo: Repository<Cattle>,
    @InjectRepository(Expense) private expenseRepo: Repository<Expense>,
    @InjectRepository(Sale) private saleRepo: Repository<Sale>,
  ) {}

  findAll(): Promise<Owner[]> {
    return this.ownerRepo.find({ order: { name: 'ASC' } });
  }

  async findOne(id: number): Promise<Owner> {
    const owner = await this.ownerRepo.findOneBy({ id });
    if (!owner) throw new NotFoundException(`Owner with id ${id} not found`);
    return owner;
  }

  async findDetails(id: number) {
    const owner = await this.findOne(id);
    const cattle = await this.cattleRepo.find({ where: { ownerId: id } });
    const expenses = await this.expenseRepo.find({ where: { ownerId: id } });

    const active = cattle.filter((c) => !c.isSold);
    const sold = cattle.filter((c) => c.isSold);

    const totalPurchaseCost = cattle.reduce((s, c) => s + c.purchasePrice, 0);
    const totalExpenses = expenses.reduce((s, e) => s + e.amount, 0);

    const soldCattleIds = sold.map((c) => c.id);
    let totalRevenue = 0;
    if (soldCattleIds.length > 0) {
      const sales = await this.saleRepo
        .createQueryBuilder('s')
        .where('s.cattle_id IN (:...ids)', { ids: soldCattleIds })
        .getMany();
      totalRevenue = sales.reduce((s, sale) => s + sale.salePrice, 0);
    }

    return {
      ...owner,
      cattle,
      summary: {
        totalCattle: cattle.length,
        activeCattle: active.length,
        soldCattle: sold.length,
        totalPurchaseCost,
        totalExpenses,
        totalRevenue,
        grandTotal: totalPurchaseCost + totalExpenses,
      },
    };
  }

  async create(dto: CreateOwnerDto): Promise<Owner> {
    const owner = this.ownerRepo.create(dto);
    return this.ownerRepo.save(owner);
  }

  async update(id: number, dto: UpdateOwnerDto): Promise<Owner> {
    const owner = await this.findOne(id);
    Object.assign(owner, dto);
    return this.ownerRepo.save(owner);
  }

  async remove(id: number): Promise<void> {
    const owner = await this.findOne(id);
    await this.ownerRepo.remove(owner);
  }
}
