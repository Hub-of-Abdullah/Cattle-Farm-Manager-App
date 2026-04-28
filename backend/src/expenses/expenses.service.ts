import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Expense } from './expense.entity';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@Injectable()
export class ExpensesService {
  constructor(
    @InjectRepository(Expense) private repo: Repository<Expense>,
  ) {}

  findAll(ownerId?: number, category?: string): Promise<Expense[]> {
    const where: any = {};
    if (ownerId !== undefined) where.ownerId = ownerId;
    if (category) where.category = category;
    return this.repo.find({ where, order: { date: 'DESC' } });
  }

  async findOne(id: number): Promise<Expense> {
    const expense = await this.repo.findOneBy({ id });
    if (!expense) throw new NotFoundException(`Expense with id ${id} not found`);
    return expense;
  }

  async create(dto: CreateExpenseDto): Promise<Expense> {
    return this.repo.save(this.repo.create(dto));
  }

  async update(id: number, dto: UpdateExpenseDto): Promise<Expense> {
    const expense = await this.findOne(id);
    Object.assign(expense, dto);
    return this.repo.save(expense);
  }

  async remove(id: number): Promise<void> {
    const expense = await this.findOne(id);
    await this.repo.remove(expense);
  }

  async totalForOwner(ownerId: number): Promise<number> {
    const result = await this.repo
      .createQueryBuilder('e')
      .select('COALESCE(SUM(e.amount), 0)', 'total')
      .where('e.owner_id = :ownerId', { ownerId })
      .getRawOne();
    return parseFloat(result.total);
  }

  findByOwner(ownerId: number): Promise<Expense[]> {
    return this.repo.find({ where: { ownerId }, order: { date: 'DESC' } });
  }
}
